extends KinematicBody
class_name Player

var speed = 0
var steeringSpeed = 0

# maximums
const maxSpeed = 16
const maxTurning = 8

func _ready():
    pass


func _process(delta):
    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    # update speed
    speed += speedInput * delta * 9
    speed = clamp(speed, 0, maxSpeed)

    # update steering
    steeringSpeed += steerInput * delta * 24
    steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)
    steeringSpeed = move_toward(steeringSpeed, 0, delta * 8)

    # bounce from the rails
    var posX = get_global_transform().origin.x
    if abs(posX) > 15:
        steeringSpeed *= -sign(posX) * sign(steeringSpeed) * .6

        if speed > 8:
            speed -= 3

        # TODO: particles


    # move the vehicle body
    translate(delta * Vector3(steeringSpeed * speed / 20, 0, -speed))



