extends CharacterBody3D
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
@export var onGrassSlowing = 7.0
@export var railHitSlowing = 4.0
@export var propHitSlowing = 2.0

@export var idleSteeringDecrease = 0.0
@export var aboveLimitSteeringDecrease = 22.0

@export var canSpin = true
@export var canTakeDamage = true

@export var wreckMaterial: Material

# Current state of the car, used by its sub-components and the AI.

var heading = 1
var speed = 0
var steering = 0

var isBreaking = false
var isSpinning = false

var spinningDirection = 0

# Maximum limits for this car model.

@onready var maxSpeed = randf_range(maxSpeedFrom, maxSpeedTo)
@onready var maxHealth = health

# Previous speeds used primarily for collision handling.

var previousSpeed = 0
var previousSteering = 0


func _ready():
    # rotate according to the heading
    if heading < 0:
        rotation.y = PI


func _process(delta):

    if canTakeDamage and health <= 0:
        destroyCar()
        return

    # update previous
    previousSpeed = speed
    previousSteering = steering

    # update speed
    if abs(speed) > maxSpeed:
        speed = move_toward(speed, 0, delta * aboveLimitSlowing)

    if isSpinning:
        speed = move_toward(speed, 0, delta * spinningSlowing)

    # slow down if on the grass
    if abs(transform.origin.x) > HighwayConstants.grass:
        speed = move_toward(speed, 0, onGrassSlowing * delta)

    # update steering
    if abs(steering) > maxSteering:
        steering = move_toward(steering, 0, delta * aboveLimitSteeringDecrease)
    else:
        steering = move_toward(steering, 0, delta * idleSteeringDecrease)


func _physics_process(delta):
    # Handle the rotation of the model. Note that only the visual model rotates, the collision shape stays the same.
    if isSpinning:
        $model.rotation.y += delta * clamp(speed, -CarConstants.spinningSpeedClamp, CarConstants.spinningSpeedClamp) * CarConstants.spinningRotation * spinningDirection
    else:
        # rotate the modal according to the steering
        $model.rotation.y = heading * -steering * CarConstants.steeringRotation

    # move the vehicle body
    var collisionInfo := move_and_collide(delta * Vector3(steering * abs(speed) * CarConstants.steeringSpeedAdjust, 0, speed * -heading))

    if collisionInfo:
        var collider := collisionInfo.get_collider()
        var normal := collisionInfo.get_normal()

        handleCollision(collider, normal)
        decreaseHealth(collider, normal)

        if collider.has_method('handleCollision'):
            collider.handleCollision(self, -normal)
        if collider.has_method('decreaseHealth'):
            collider.decreaseHealth(self, -normal)

        # TODO: what about the remainder?


func handleCollision(collider: Object, normal: Vector3):

    # *Note to self*: both cars will call this on collision, so only handle this car here!
    # *Another note*: I had to add previousSpeed to make this work, because without it the cars would always
    # just swap speeds (given that both would process this code and the second one would work with the speeds
    # set by the first one)!

    # check if the other collider is a car
    if 'heading' in collider and 'previousSpeed' in collider and 'previousSteering' in collider:

        var otherSpeed = collider.previousSpeed * collider.heading
        var ourSpeed = previousSpeed * heading
        var otherSteering = collider.previousSteering
        var ourSteering = previousSteering

        var diff = otherSpeed - ourSpeed
        var diffSteering = otherSteering - ourSteering

        var avgMass = (mass + collider.mass) / 2
        diff *= collider.mass / avgMass
        diffSteering *= collider.mass / avgMass


        if abs(normal.x) > abs(normal.z) or abs(previousSpeed - collider.previousSpeed) > 4:
            steering += diffSteering * CarConstants.collisionSteeringMultiplier

        if abs(normal.z) > abs(normal.x) or abs(previousSpeed) < abs(collider.previousSpeed):
            speed += heading * diff * CarConstants.collisionSpeedMultiplier


    # bounce from the rails
    elif collider.get_collision_layer_bit(1):
        steering *= -CarConstants.collisionSteeringMultiplier
        speed = move_toward(speed, 0, railHitSlowing)


    else:
        # hit something solid
        speed = move_toward(speed, 0, propHitSlowing)

    emit_signal('collided', collider, normal)


func decreaseHealth(collider: Object, normal: Vector3):

    if 'heading' in collider and 'previousSpeed' in collider and 'previousSpeed' in collider:
        var otherSpeed = collider.previousSpeed * collider.heading
        var ourSpeed = previousSpeed * heading

        var diff = CarConstants.collisionHealthSpeedMultipler * abs(otherSpeed - ourSpeed)
        var diffSteering = CarConstants.collisionHealthSteeringMultipler * abs(collider.previousSteering - previousSteering)

        var total

        if abs(normal.z) > abs(normal.x):
            total = diff
        else:
            total = diffSteering

        if total > 2 and canTakeDamage:
            health -= total

        if canSpin and (total > CarConstants.collisionSpinningThreshold or health/maxHealth < CarConstants.healthSpinningThreshold):
            isSpinning = true
            spinningDirection = sign(collider.transform.origin.x - transform.origin.x)
            emit_signal('spinned')

func destroyCar():
    emit_signal('destroyed')

    var newNode := DynamicObject.new()

    for group in get_groups():
        newNode.add_to_group(group)

    newNode.collision_layer = 0
    newNode.set_collision_layer_bit(6, true)

    newNode.collision_mask = 0
    for i in range(8):
        newNode.set_collision_mask_bit(i, true)

    # rotate the whole object according to the previous rotation of the model
    newNode.rotation = $model.rotation
    $model.rotation = Vector3.ZERO

    # move the collision box to the center to have the correct center of gravity
    var offset = $collision.shape.extents.y

    newNode.transform = transform.translated(Vector3.UP * offset)
    $collision.translate(Vector3.DOWN * offset)
    $model.translate(Vector3.DOWN * offset)

    # add force according to the current movement, and a random rotation
    newNode.apply_impulse(Vector3.ZERO, Vector3(steering, 0, speed * -heading))

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
