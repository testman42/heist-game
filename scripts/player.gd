extends Spatial

var steeringSpeed = 0

# maximums
const maxSpeed = 16
const maxTurning = .16

func _ready():

    # reset the player speed when starting
    LevelSpeed.speed = 2


func _process(delta):

    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    # update speed
    LevelSpeed.speed += speedInput * delta * 5
    LevelSpeed.speed = clamp(LevelSpeed.speed, 0, maxSpeed)

    # update position
    steeringSpeed += steerInput * delta * .42
    steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)
    steeringSpeed = move_toward(steeringSpeed, 0, .0026)

    translate(Vector3(steeringSpeed * LevelSpeed.speed / 10, 0, 0))

