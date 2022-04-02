extends Spatial

var steeringSpeed = 0

# maximums
const maxSpeed = 16
const maxTurning = .16

func _ready():

    # reset the player speed when starting
    LevelSpeed.speed = 0


func _process(delta):

    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    # update speed
    LevelSpeed.speed += speedInput * delta * 5
    LevelSpeed.speed = clamp(LevelSpeed.speed, 0, maxSpeed)

    # update steering
    steeringSpeed += steerInput * delta * .42
    steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)
    steeringSpeed = move_toward(steeringSpeed, 0, .0026)

    # bounce from the rails
    var posX = get_global_transform().origin.x
    if abs(posX) > 15:
        steeringSpeed *= -sign(posX) * sign(steeringSpeed)

        if LevelSpeed.speed > 8:
            LevelSpeed.speed -= 3
            LevelSpeed.speed = clamp(LevelSpeed.speed, 0, maxSpeed)

        # TODO: particles


    # move the vehicle sideways
    translate(Vector3(steeringSpeed * LevelSpeed.speed / 10, 0, 0))



