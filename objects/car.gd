extends DynamicObject
class_name Car

# Car that is just driving around, about to be wrecked by the player.
# Contains the probability that this particular model will spawn.

export var spawnProbability = 1.0

var heading = 1
var speed = 0
var steeringSpeed = 0

# maximums
var maxSpeed = rand_range(8, 14)
var maxTurning = 14

func _process(delta):

    # update speed
    speed = clamp(speed, -maxSpeed, maxSpeed)

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


    # move the vehicle body
    translate(delta * Vector3(steeringSpeed * speed / 20, 0, -speed))

    # rotate the modal according to the steering
    if $model != null:
        $model.rotation.y = -steeringSpeed / 30

