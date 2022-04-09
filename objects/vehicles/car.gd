extends DynamicObjectKinematic
class_name Car

# This is the base class for all cars in the game. It handles collision and
# physics of vehicles, emits signals, handles the health and damage of the car, etc.

signal collided
signal spinned
signal destroyed

signal startBreaking
signal stopBreaking

# Properties of this car model.

export var spawnProbability = 1.0
export var health = 200.0

export var maxSpeedFrom = 10.0
export var maxSpeedTo = 14.0
export var maxSteering = 14.0

export var acceleration = 8.0
export var breakingForce = 6.0
export var steeringForce = 14.0

export var idleSlowing = 0.0
export var aboveLimitSlowing = 2.4
export var spinningSlowing = 8.0
export var onGrassSlowing = 7.0
export var railHitSlowing = 4.0
export var propHitSlowing = 2.0

export var idleSteeringDecrease = 8.0
export var aboveLimitSteeringDecrease = 22.0

export var canSpin = true
export var canTakeDamage = true

export(SpatialMaterial) var wreckMaterial

# Current state of the car, used by its sub-components and the AI.

var heading = 1
var speed = 0
var steering = 0

var isBreaking = false
var isSpinning = false

# Maximums limits for this car model.

onready var maxSpeed = rand_range(maxSpeedFrom, maxSpeedTo)
onready var maxHealth = health

# Previous speeds used primarily for collision handling.

var previousSpeed = 0
var previousSteering = 0

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
    if abs(transform.origin.x) > 11:
        speed = move_toward(speed, 0, onGrassSlowing * delta)

    # update steering
    if abs(steering) > maxSteering:
        steering = move_toward(steering, 0, delta * aboveLimitSteeringDecrease)
    else:
        steering = move_toward(steering, 0, delta * idleSteeringDecrease)

    # bounce from the rails
    var posX = transform.origin.x
    if abs(posX) > 15:
        transform.origin.x = 15 * sign(posX)
        steering *= -.9
        speed = move_toward(speed, 0, delta * railHitSlowing)


func _physics_process(delta):
    # Handle the rotation of the model. Note that only the visual model rotates, the collision shape stays the same.
    if isSpinning:
        $model.rotation.y += delta * speed * -1.6
    else:
        # rotate the modal according to the steering
        $model.rotation.y = -steering / 30

    # move the vehicle body
    translate(delta * Vector3(steering * speed / 20, 0, -speed))


func _on_car_body_entered(body):
    # Called when this car collides with another one.
    handleCollision(body)
    decreaseHealth(body)


func handleCollision(body):

    # *Note to self*: both cars will call this on collision, so only handle this car here!
    # *Another note*: I had to add previousSpeed to make this work, because without it the cars would always
    # just swap speeds (given that both would process this code and the second one would work with the speeds
    # set by the first one)!

    # check if the other body is a car
    if 'heading' in body and 'previousSpeed' in body and 'previousSteering' in body:

        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading
        var otherSteering = body.previousSteering * body.heading
        var ourSteering = previousSteering * heading

        var diff = otherSpeed - ourSpeed
        var diffSteering = otherSteering - ourSteering

        speed += heading * diff * .9
        steering += diffSteering * .9

        # ensure some minimum diff is applied to make the cars
        # bounce from each other and not "merge" into one - see #2
        if abs(diff) < 4:
            speed += heading * sign(diff) * 1.5
        if abs(diffSteering) < 4:
            steering += sign(diffSteering) * 1.5


    else:
        # hit something solid
        speed = move_toward(speed, 0, propHitSlowing)


func decreaseHealth(body):

    if 'heading' in body and 'previousSpeed' in body and 'previousSpeed' in body:
        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading

        var diff = .8 * abs(otherSpeed - ourSpeed)
        var diffSteering = .6 * abs(body.previousSteering - previousSteering)
        var total = diff + diffSteering

        if total > 2 and canTakeDamage:
            health -= total

        if canSpin and (total > 16 or health/maxHealth < .2):
            isSpinning = true
            emit_signal('spinned')


func destroyCar():
    call_deferred('set_script', null)
    emit_signal('destroyed')

    # TODO: implement changing to a rigid body node

    # swap the kinetic body mode for rigid body
    #mode = MODE_RIGID

    # add the ground collision mask
    set_collision_mask_bit(11, true)

    # add force according to the current movement, and a random rotation
    #apply_impulse(Vector3.ZERO, Vector3(steering, 0, speed * -heading))

    var amount = 10
    var spinningSpeed = 0
    if isSpinning:
        spinningSpeed = -sign(steering) * rand_range(4, 10)

    #apply_torque_impulse(Vector3(rand_range(-amount, amount), -spinningSpeed, rand_range(-amount, amount)))

    # turn into a wreck
    get_node('model/wheels').queue_free()
    get_node('model/height-adjust/lights').queue_free()

    var policeLights = get_node_or_null('model/height-adjust/police-lights')
    if policeLights:
        policeLights.queue_free()

    var parts = get_node('model/height-adjust').get_children()
    for part in parts:
        if 'material' in part:
            part.material = wreckMaterial


func setBreaking(value: bool):
    # handles the breaking signals and the breaking state
    if isBreaking == value:
        return

    isBreaking = value

    if isBreaking:
        emit_signal('startBreaking')
    else:
        emit_signal('stopBreaking')
