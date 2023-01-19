extends DynamicObjectKinematic
class_name Car

# This is the base class for all cars in the game. It handles collision and
# physics of vehicles, emits signals, handles the health and damage of the car, etc.
# Needs to be controlled by some kind of input - AI or player.

signal collided
signal spinned
signal destroyed

signal startBreaking
signal stopBreaking

# Properties of this car model.

@export var spawnProbability = 1.0
@export var health = 200.0
@export var mass = 1000.0

@export var maxSpeedFrom = 10.0
@export var maxSpeedTo = 14.0
@export var maxSteering = 14.0

@export var acceleration = 4.0
@export var breakingForce = 6.0
@export var steeringForce = 2.0

@export var idleSlowing = 0.0
@export var aboveLimitSlowing = 2.4
@export var spinningSlowing = 8.0

@export var idleSteeringDecrease = 0.0
@export var aboveLimitSteeringDecrease = 22.0

@export var canSpin = true
@export var canTakeDamage = true

@export var wreckMaterial: Material

# Current state of the car, used by its sub-components and the AI.

var heading := 1 # 1 means up (-Z), -1 means down (+Z)
var speed := 0.0 # positive means going forward, negative going backwards
var steering := 0.0 # always matches the X axis

var isBreaking := false
var isSpinning := false
var isDestroyed := false

var spinningDirection := 0

# Maximum limits for this car model.

@onready var maxSpeed = randf_range(maxSpeedFrom, maxSpeedTo)
@onready var maxHealth = health

# Previous speeds used primarily for collision handling.

var previousSpeed := 0.0
var previousSteering := 0.0



func _process(delta: float):
    super(delta)

    # sometimes for some reason, cars end up being in air :shrug: so just in case, reset the Y position
    position.y = 0

    if canTakeDamage and health <= 0:
        isDestroyed = true
        emit_signal('destroyed')
        destroyCar(true)
        return

    # update previous
    previousSpeed = speed
    previousSteering = steering

    # update speed
    if absf(speed) > maxSpeed:
        speed = move_toward(speed, 0, delta * aboveLimitSlowing)

    if isSpinning:
        speed = move_toward(speed, 0, delta * spinningSlowing)

    # update steering
    if abs(steering) > maxSteering:
        steering = move_toward(steering, 0, delta * aboveLimitSteeringDecrease)
    else:
        steering = move_toward(steering, 0, delta * idleSteeringDecrease)

    # Handle the rotation of the car.
    rotation.y = heading * -steering * CarConstants.steeringRotation
    if heading < 0: rotation.y += PI


func _physics_process(delta: float):

    # move the vehicle body
    var collisionInfo := move_and_collide(delta * Vector3(steering * abs(speed) * CarConstants.steeringSpeedAdjust, 0, speed * -heading))

    if collisionInfo == null:
        # no collision occured, we're done here
        return

    var collider := collisionInfo.get_collider()
    var normal := collisionInfo.get_normal()
    var pos := collisionInfo.get_position()

    handleCollision(collider, normal, pos)

    if collider.has_method('handleCollision'):
        collider.handleCollision(self, -normal, pos)

    # move forward/back using the remainder so we don't get
    # stuck in the other collider and basically "slide" along it
    if not isSpinning and not isDestroyed:
        var remainderZ := collisionInfo.get_remainder().z
        move_and_collide(Vector3(0, 0, remainderZ))


func handleCollision(collider: CollisionObject3D, normal: Vector3, pos: Vector3):

    # *Note to self*: both cars will call this on collision, so only handle this car here!
    # *Another note*: I had to add previousSpeed to make this work, because without it the cars would always
    # just swap speeds (given that both would process this code and the second one would work with the speeds
    # set by the first one)!
    # This code took a lot of tinkering to get right... and it still isn't 100% right...

    # check if the other collider is a CAR or a PROP
    if ('heading' in collider and 'previousSpeed' in collider and 'previousSteering' in collider) or ('linear_velocity' in collider):

        var otherSpeed: float
        var otherSteering: float

        if 'linear_velocity' in collider:
            otherSpeed = -collider.linear_velocity.z
            otherSteering = collider.linear_velocity.x
        else:
            otherSpeed = collider.previousSpeed * collider.heading
            otherSteering = collider.previousSteering

        var ourSpeed := previousSpeed * heading
        var ourSteering := previousSteering

        var diff := otherSpeed - ourSpeed
        var diffSteering := otherSteering - ourSteering

        var avgMass: float = (mass + collider.mass) / 2
        diff *= collider.mass / avgMass
        diffSteering *= collider.mass / avgMass

        # Given that the colliders rotate with the car now, we can no longer count on the fact that
        # the collision normal will always be either on the Z or the X axis. Now we need to calculate
        # the dot product of the collision normal and the velocity to see how much the speed and steering
        # needs to be affected.
        # NOTE that the collision normal points from the other collider's shape towards this car.

        var speedMultiplier = absf(normal.dot(Vector3.BACK))
        var steeringMultiplier = absf(normal.dot(Vector3.RIGHT))

        diff *= speedMultiplier
        diffSteering *= steeringMultiplier

        # Safety check: This handles a specific edge case that happens right after a collision has been resolved.
        # When a collision has been resolved and the cars have new steering velocities - the one which caused the
        # collision has lower steering and the other one has higher steering to move away - it is possible that next
        # frame the car with lower steering will be processed first and bump into the car it collided with last frame
        # again. In this case, we need to ignore the collision because the other car will move away faster anyway.
        # NOTE! DON'T ignore the whole collision because maybe the one (speed or steering) needs to be ignored!
        # Just ignore that part and handle the other.
        if absf(normal.x) > 0 and signf(diffSteering) != signf(normal.x):
            diffSteering = 0
        if absf(normal.z) > 0 and signf(diff) != -signf(normal.z): # note the -1! because positive heading means -Z axis
            diff = 0

        # update steering and speed after the collision
        steering += diffSteering * CarConstants.collisionSteeringMultiplier
        speed += heading * diff * CarConstants.collisionSpeedMultiplier

        # update health
        var total := absf(diff) + absf(diffSteering)

        if total > 2 and canTakeDamage:
            health -= total

        if canSpin and (total > CarConstants.collisionSpinningThreshold or health/maxHealth < CarConstants.healthSpinningThreshold):
            isSpinning = true
            spinningDirection = int(signf(collider.transform.origin.x - transform.origin.x))

            # spinning the car turns it into a car prop
            emit_signal('spinned')
            destroyCar(false)

        # break parts on the car
        if total >= CarConstants.collisionBreakThreshold:

            # find the breakable part closest to the collision point, if any
            var part := findClosestBreakableNode(self, pos, 1.6)
            if part == null: return

            part.remove_from_group('breakable')

            if part.has_method('breakOff'):
                part.breakOff()


    # static colliders
    elif collider is StaticBody3D:
        if absf(normal.x) > 0:
            # bounce from the highway rails
            steering *= -CarConstants.collisionSteeringMultiplier
        if absf(normal.z) > 0:
            # uh oh, this is a crude solution when a car crashes head-on into a static collider
            health = 0
            speed = 0


    # other colliders like props won't be matched here, otherwise
    # the car would just stop immediately due to move_and_collide

    emit_signal('collided')


# Searches node's children (deep) and finds the closest breakable node to the provided
# position. Only considers nodes that are closer than the maxDistance. NOTE: maxDistance is squared.
func findClosestBreakableNode(node: Node, pos: Vector3, maxDistance: float) -> Node:

    var bestNode: Node
    var bestDistance := maxDistance

    for child in node.get_children():
        if child.is_in_group('breakable'):
            var dist = child.global_position.distance_squared_to(pos)
            if dist < bestDistance:
                bestNode = child
                bestDistance = dist

        if child.get_child_count() > 0:
            var nested = findClosestBreakableNode(child, pos, bestDistance)
            if nested != null:
                var dist = nested.global_position.distance_squared_to(pos)
                if dist < bestDistance:
                    bestNode = nested
                    bestDistance = dist

    return bestNode



func destroyCar(turnIntoWreck: bool):

    if isSpinning: return
    if isDestroyed: return

    var newNode := Prop.new()

    newNode.add_to_group('wreck')

    newNode.mass = mass

    newNode.collision_layer = 0
    newNode.set_collision_layer_value(7, true)

    newNode.collision_mask = 0
    for i in range(1, 8):
        newNode.set_collision_mask_value(i, true)

    # rotate the whole object according to the previous rotation of the model
    newNode.rotation = rotation

    # move the collision box to the center to have the correct center of gravity
    var offset = $collision.shape.extents.y

    newNode.transform = transform.translated(Vector3.UP * offset)

    for child in get_children():
        child.translate(Vector3.DOWN * offset)

    # delete parts that should not appear on a wreck

    if turnIntoWreck:

        # TODO: turn wheels into props
        get_node('model/wheels').queue_free()
        get_node('model/lights').queue_free()

        var policeLights = get_node_or_null('model/police-lights')
        if policeLights != null:
            policeLights.queue_free()

        # assign the wreck material to visible parts
        var parts = $model.get_children()
        for part in parts:
            if 'material' in part:
                part.material = wreckMaterial

    # move child nodes over
    for child in get_children():
        remove_child(child)
        newNode.add_child(child)

    # add the new node to the tree
    get_tree().root.add_child(newNode)

    # add force according to the current movement, and a random rotation
    newNode.apply_impulse(Vector3(steering, randf_range(0, 2), speed * -heading))

    queue_free()


func setBreaking(value: bool):
    # handles the breaking signals and the breaking state
    if isBreaking == value:
        return

    isBreaking = value

    if isBreaking:
        emit_signal('startBreaking')
    else:
        emit_signal('stopBreaking')
