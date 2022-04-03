extends DynamicObject
class_name Car

# Car that is just driving around, about to be wrecked by the player.
# Contains the probability that this particular model will spawn.

signal spinned
signal destroyed

export var spawnProbability = 1.0
export var maxSpeedFrom = 8
export var maxSpeedTo = 14
export var health = 200

var heading = 1
var speed = 0
var steeringSpeed = 0
var spinning = false
var spinningSpeed = 0

# maximums
onready var maxSpeed = rand_range(maxSpeedFrom, maxSpeedTo)
var maxTurning = 14

# previous speeds used for collisions
var previousSpeed = 0
var previousSteeringSpeed = 0

func _process(delta):

    if health <= 0:
        destroyCar()

    # update previous
    previousSpeed = speed
    previousSteeringSpeed = steeringSpeed


    # update speed
    # speed = clamp(speed, -maxSpeed, maxSpeed)
    if speed > maxSpeed:
        speed -= .72 * delta

    if spinning:
        speed = move_toward(speed, 0, delta * 8)

    # update steering
    steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)
    steeringSpeed = move_toward(steeringSpeed, 0, delta * 8)

    # bounce from the rails
    var posX = transform.origin.x
    if abs(posX) > 15:
        steeringSpeed *= -sign(posX) * sign(steeringSpeed) * .9

        if abs(speed) > 8:
            speed -= 2 * sign(speed)

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

    if 'heading' in body and 'previousSpeed' in body:
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
        if speed > 6:
            speed -= 2.5


    if 'previousSteeringSpeed' in body:
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

    else:
        # hit something solid
        steeringSpeed *= -.9

func decreaseHealth(body):

    if 'heading' in body and 'previousSpeed' in body:
        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading
        var diff = abs(otherSpeed - ourSpeed)

        health -= diff * 1.2

        if diff > 14:
            spinning = true
            spinningSpeed = rand_range(-diff / 20, diff / 20)
            emit_signal('spinned')

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
    emit_signal('destroyed')

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

    var parts = get_node('model/height-adjust').get_children()
    for part in parts:
        if not 'material' in part:
            continue

        part.material = part.material.duplicate()
        part.material.albedo_color = Color(.1, .1, .1)

