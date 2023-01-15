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
@export var mass = 1.0

@export var maxSpeedFrom = 10.0
@export var maxSpeedTo = 14.0
@export var maxSteering = 14.0

@export var acceleration = 4.0
@export var breakingForce = 6.0
@export var steeringForce = 2.0

@export var idleSlowing = 0.0
@export var aboveLimitSlowing = 2.4
@export var spinningSlowing = 8.0
@export var railHitSlowing = 4.0
@export var propHitSlowing = 2.0

@export var idleSteeringDecrease = 0.0
@export var aboveLimitSteeringDecrease = 22.0

@export var canSpin = true
@export var canTakeDamage = true

@export var wreckMaterial: Material

# Current state of the car, used by its sub-components and the AI.

var heading := 1 # 1 means up (-Z), -1 means down (+Z)
var speed := 0.0
var steering := 0.0

var isBreaking := false
var isSpinning := false

var spinningDirection := 0

# Maximum limits for this car model.

@onready var maxSpeed = randf_range(maxSpeedFrom, maxSpeedTo)
@onready var maxHealth = health

# Previous speeds used primarily for collision handling.

var previousSpeed := 0.0
var previousSteering := 0.0


func _ready():
    super()

    # rotate according to the heading
    if heading < 0:
        rotation.y = PI


func _process(delta: float):
    super(delta)

    if canTakeDamage and health <= 0:
        destroyCar()
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

    # Handle the rotation of the model. Note that only the visual model rotates, the collision shape stays the same.
    if isSpinning:
        $model.rotation.y += delta * clampf(speed, -CarConstants.spinningSpeedClamp, CarConstants.spinningSpeedClamp) * CarConstants.spinningRotation * spinningDirection
    else:
        # rotate the modal according to the steering
        $model.rotation.y = heading * -steering * CarConstants.steeringRotation


func _physics_process(delta: float):

    # move the vehicle body
    var collisionInfo := move_and_collide(delta * Vector3(steering * abs(speed) * CarConstants.steeringSpeedAdjust, 0, speed * -heading))

    if collisionInfo != null:
        var collider := collisionInfo.get_collider()
        var normal := collisionInfo.get_normal()
        var pos := collisionInfo.get_position()

        handleCollision(collider, normal)
        decreaseHealth(collider, normal)
        breakParts(pos, collider, normal)

        if collider.has_method('handleCollision'):
            collider.handleCollision(self, -normal)
        if collider.has_method('decreaseHealth'):
            collider.decreaseHealth(self, -normal)
        if collider.has_method('breakParts'):
            collider.breakParts(pos, self, -normal)

        # TODO: what about the remainder?


func handleCollision(collider: CollisionObject3D, normal: Vector3):

    # *Note to self*: both cars will call this on collision, so only handle this car here!
    # *Another note*: I had to add previousSpeed to make this work, because without it the cars would always
    # just swap speeds (given that both would process this code and the second one would work with the speeds
    # set by the first one)!
    # This code took a lot of tinkering to get right...

    # check if the other collider is a car
    if 'heading' in collider and 'previousSpeed' in collider and 'previousSteering' in collider:

        var otherSpeed: float = collider.previousSpeed * collider.heading
        var ourSpeed := previousSpeed * heading
        var otherSteering: float = collider.previousSteering
        var ourSteering := previousSteering

        var diff := otherSpeed - ourSpeed
        var diffSteering := otherSteering - ourSteering

        var avgMass: float = (mass + collider.mass) / 2
        diff *= collider.mass / avgMass
        diffSteering *= collider.mass / avgMass

        # Safety check: This handles a specific edge case that happens right after a collision has been resolved.
        # When a collision has been resolved and the cars have new steering velocities - the one which caused the
        # collision has lower steering and the other one has higher steering to move away - it is possible that next
        # frame the car with lower steering will be processed first and bump into the car it collided with last frame
        # again. In this case, we need to ignore the collision because the other car will move away faster anyway.
        if absf(normal.x) > 0 and signf(diffSteering) != signf(normal.x):
            return
        if absf(normal.z) > 0 and signf(diff) != -signf(normal.z): # note the -1! because positive heading means -Z axis
            return

        # handle side collisions, only if the collision is large enough and
        # we are not just touching bumpers
        if absf(normal.x) > 0 or absf(diff) > 4:
            steering += diffSteering * CarConstants.collisionSteeringMultiplier

        # handle front/back collisions, only if the collision normal is on the Z axis
        if absf(normal.z) > 0:
            speed += heading * diff * CarConstants.collisionSpeedMultiplier


    # bounce from the rails
    elif collider.get_collision_layer_value(2):
        steering *= -CarConstants.collisionSteeringMultiplier
        speed = move_toward(speed, 0, railHitSlowing)


    else:
        # hit something solid
        speed = move_toward(speed, 0, propHitSlowing)

    emit_signal('collided')


func decreaseHealth(collider: Object, normal: Vector3):

    if 'heading' in collider and 'previousSpeed' in collider and 'previousSpeed' in collider:
        var otherSpeed: float = collider.previousSpeed * collider.heading
        var ourSpeed := previousSpeed * heading

        var diff := CarConstants.collisionHealthSpeedMultipler * absf(otherSpeed - ourSpeed)
        var diffSteering := CarConstants.collisionHealthSteeringMultipler * absf(collider.previousSteering - previousSteering)

        var total: float

        if absf(normal.z) > absf(normal.x):
            total = diff
        else:
            total = diffSteering

        if total > 2 and canTakeDamage:
            health -= total

        if canSpin and (total > CarConstants.collisionSpinningThreshold or health/maxHealth < CarConstants.healthSpinningThreshold):
            isSpinning = true
            spinningDirection = int(signf(collider.transform.origin.x - transform.origin.x))
            emit_signal('spinned')


func breakParts(pos: Vector3, collider: CollisionObject3D, normal: Vector3):

    var total := 0.0

    if 'heading' in collider and 'previousSpeed' in collider and 'previousSpeed' in collider:
        var otherSpeed: float = collider.previousSpeed * collider.heading
        var ourSpeed := previousSpeed * heading

        var diff := CarConstants.collisionBreakSpeedMultipler * absf(otherSpeed - ourSpeed)
        var diffSteering := CarConstants.collisionBreakSteeringMultipler * absf(collider.previousSteering - previousSteering)

        if absf(normal.z) > absf(normal.x):
            total = diff
        else:
            total = diffSteering

    else:
        if absf(normal.z) > absf(normal.x):
            total = CarConstants.collisionBreakSpeedMultipler * absf(previousSpeed)
        else:
            total = CarConstants.collisionBreakSteeringMultipler * absf(previousSteering)

    if total < CarConstants.collisionBreakThreshold:
        # too weak collision
        return

    # find the breakable part closest to the collision point, if any
    var part := findClosestBreakableNode(self, pos, 2)
    if part == null: return

    part.remove_from_group('breakable')

    if part.has_method('breakOff'):
        part.breakOff()

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



func destroyCar():
    emit_signal('destroyed')

    var newNode := DynamicObject.new()

    for group in get_groups():
        newNode.add_to_group(group)

    newNode.collision_layer = 0
    newNode.set_collision_layer_value(7, true)

    newNode.collision_mask = 0
    for i in range(1, 8):
        newNode.set_collision_mask_value(i, true)

    # rotate the whole object according to the previous rotation of the model
    newNode.rotation = $model.rotation
    $model.rotation = Vector3.ZERO

    # move the collision box to the center to have the correct center of gravity
    var offset = $collision.shape.extents.y

    newNode.transform = transform.translated(Vector3.UP * offset)
    $collision.translate(Vector3.DOWN * offset)
    $model.translate(Vector3.DOWN * offset)

    # add force according to the current movement, and a random rotation
    newNode.apply_impulse(Vector3(steering, 0, speed * -heading))

    newNode.apply_torque_impulse(Vector3(
        0,
        clamp(speed, -CarConstants.spinningSpeedClamp, CarConstants.spinningSpeedClamp) * CarConstants.spinningRotation * spinningDirection,
        0
    ))

    # delete parts that should not appear on a wreck

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
    var collision = $collision
    var model = $model

    remove_child(collision)
    remove_child(model)
    newNode.add_child(collision)
    newNode.add_child(model)

    # swap nodes
    var parent = get_parent()
    parent.remove_child(self)
    parent.add_child(newNode)

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
