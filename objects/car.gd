extends DynamicObject
class_name Car

# Car that is just driving around, about to be wrecked by the player.
# Contains the probability that this particular model will spawn.

signal spinned
signal destroyed

signal startBreaking
signal stopBreaking

# Properties of this car model.

export var spawnProbability = 1.0
export var maxSpeedFrom = 8
export var maxSpeedTo = 14
export var health = 200

export(SpatialMaterial) var wreckMaterial

# Current state of the car, used by its sub-components and the AI.

var heading = 1
var speed = 0
var steeringSpeed = 0

var spinning = false
var spinningSpeed = 0

var isBreaking = false

# Maximums limits for this car model.

onready var maxSpeed = rand_range(maxSpeedFrom, maxSpeedTo)
var maxTurning = 14

# Previous speeds used primarily for collision handling.

var previousSpeed = 0
var previousSteeringSpeed = 0

func _process(delta):

    if health <= 0:
        destroyCar()
        return



    # update previous
    previousSpeed = speed
    previousSteeringSpeed = steeringSpeed


    # update speed
    # speed = clamp(speed, -maxSpeed, maxSpeed)
    if abs(speed) > maxSpeed:
        speed = move_toward(speed, 0, delta * 1.6)

    if spinning:
        speed = move_toward(speed, 0, delta * 8)

    # update steering
    # steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)

    if abs(steeringSpeed) > maxTurning:
        steeringSpeed = move_toward(steeringSpeed, 0, delta * 22)
    else:
        steeringSpeed = move_toward(steeringSpeed, 0, delta * 8)

    # bounce from the rails
    var posX = transform.origin.x
    if abs(posX) > 15:
        transform.origin.x = 15 * sign(posX)
        steeringSpeed *= -sign(posX) * sign(steeringSpeed) * .9

        if abs(speed) > 2:
            speed = move_toward(speed, 0, delta * 4)

        var transform = Transform(global_transform)
        transform.origin.x += -sign(steeringSpeed) * 1.2
        ParticleEffect.spawnCollisionSparks(transform, 10, Vector3(-steeringSpeed, 2, -speed))


func _physics_process(delta):
    # move the vehicle body
    translate(delta * Vector3(steeringSpeed * speed / 20, 0, -speed))

    if $model:

        if spinning:
            var amount = delta * .4 * speed * spinningSpeed
            $model.rotation.y += amount
        else:
            # rotate the modal according to the steering
            $model.rotation.y = -steeringSpeed / 30




func _on_car_body_entered(body):
    # Called when this car collides with another one.
    handleCollision(body)
    decreaseHealth(body)


func handleCollision(body):

    # *Note to self*: both cars will call this on collision, so only handle this car here!
    # *Another note*: I had to add previousSpeed to make this work, because without it the cars would always
    # just swap speeds (given that both would process this code and the second one would work with the speeds
    # set by the first one)!

    var diffPos = body.transform.origin - transform.origin

    if 'heading' in body and 'previousSpeed' in body:

        # only adjust speed if crashing to the back or the front of the car
        if abs(diffPos.z) > .6:
            var otherSpeed = body.previousSpeed * body.heading
            var ourSpeed = previousSpeed * heading
            var diff = otherSpeed - ourSpeed

            # add random steering
            steeringSpeed += rand_range(-.1, .1)

            # update speed
            if body.is_in_group('player'):
                # the player is stronger
                speed += heading * diff * 1.6
            else:
                speed += heading * diff * .9

            # particles
            if abs(diff) > 6:
                var transform = Transform()
                transform.origin = lerp(global_transform.origin, body.global_transform.origin, .5)
                transform.origin.y = .8
                ParticleEffect.spawnCollisionSparks(transform, abs(diff) / 4, Vector3(previousSteeringSpeed, 2, -ourSpeed))

    else:
        # hit something solid
        speed = move_toward(speed, 0, 1.5)


    if 'previousSteeringSpeed' in body:

        # only adjust speed if crashing to the side of the car
        if abs(diffPos.x) > .2:
            var diff = body.previousSteeringSpeed - previousSteeringSpeed

            # update steering
            if body.is_in_group('player'):
                # the player is stronger
                steeringSpeed += diff * 1.6
            else:
                steeringSpeed += diff * .9

            # particles
            if abs(diff) > 6:
                var transform = Transform()
                transform.origin = lerp(global_transform.origin, body.global_transform.origin, .5)
                transform.origin.y = .8
                ParticleEffect.spawnCollisionSparks(transform, abs(diff) / 4, Vector3(previousSteeringSpeed, 2, previousSpeed * -heading))

func decreaseHealth(body):

    if 'heading' in body and 'previousSpeed' in body:
        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading
        var diff = abs(otherSpeed - ourSpeed)

        health -= diff * 1.2

        if diff > 14:
            spinning = true
            spinningSpeed = rand_range(-diff / 20, diff / 20)
            emit_signal('spinned', self)

    else:
        # hit something solid
        health -= abs(speed) / 6


    if 'previousSteeringSpeed' in body:
        var diff = abs(body.previousSteeringSpeed - previousSteeringSpeed)
        health -= diff * 2

        if diff > 10:
            spinning = true
            spinningSpeed = rand_range(0, diff / 10) * -sign(body.previousSteeringSpeed - previousSteeringSpeed)

    else:
        # hit something solid
        health -= abs(steeringSpeed) / 20

func destroyCar():
    call_deferred('set_script', null)
    emit_signal('destroyed', self)

    # disable collision reporting
    disconnect('body_entered', self, '_on_car_body_entered')
    contact_monitor = false

    # swap the kinetic body mode for rigid body
    mode = MODE_RIGID

    # add the ground collision mask
    collision_mask |= 1 << 11

    # add force according to the current movement, and a random rotation
    apply_impulse(Vector3.ZERO, Vector3(steeringSpeed, 0, speed * -heading))

    var amount = 10
    apply_torque_impulse(Vector3(rand_range(-amount, amount), spinningSpeed, rand_range(-amount, amount)))

    # particles
    ParticleEffect.spawnExplosion(global_transform, Vector3(steeringSpeed, 1, speed * -heading))

    # turn into a wreck
    get_node('model/wheels').queue_free()
    get_node('model/height-adjust/lights').queue_free()

    var policeLights = get_node('model/height-adjust/police-lights')
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
