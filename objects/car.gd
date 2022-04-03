extends DynamicObject
class_name Car

# Car that is just driving around, about to be wrecked by the player.
# Contains the probability that this particular model will spawn.

export var spawnProbability = 1.0
export var maxSpeedFrom = 8
export var maxSpeedTo = 14

var heading = 1
var speed = 0
var steeringSpeed = 0

# maximums
onready var maxSpeed = rand_range(maxSpeedFrom, maxSpeedTo)
var maxTurning = 14

# previous speeds used for collisions
var previousSpeed = 0
var previousSteeringSpeed = 0

func _process(delta):

    # update previous
    previousSpeed = speed
    previousSteeringSpeed = steeringSpeed


    # update speed
    # speed = clamp(speed, -maxSpeed, maxSpeed)
    if speed > maxSpeed:
        speed -= .72 * delta

    # update steering
    steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)
    steeringSpeed = move_toward(steeringSpeed, 0, delta * 8)

    # bounce from the rails
    var posX = transform.origin.x
    if abs(posX) > 15:
        steeringSpeed *= -sign(posX) * sign(steeringSpeed) * .9

        if abs(speed) > 8:
            speed -= 2 * sign(speed)

        # TODO: particles


func _physics_process(delta):
    # move the vehicle body
    translate(delta * Vector3(steeringSpeed * speed / 20, 0, -speed))

    # rotate the modal according to the steering
    if $model != null:
        $model.rotation.y = -steeringSpeed / 30




func _on_car_body_entered(body):
    # Called when this car collides with another one.
    # *Note to self*: both cars will call this on collision, so only handle this car here.

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

    else:
        # hit something solid
        speed = 0


    if 'previousSteeringSpeed' in body:
        var diff = body.previousSteeringSpeed - previousSteeringSpeed

        # update steering
        if body.is_in_group('player'):
            # the player is stronger
            steeringSpeed += diff * 1.6
        else:
            steeringSpeed += diff * .9

    else:
        # hit something solid
        steeringSpeed *= -.9
