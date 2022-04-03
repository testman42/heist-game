extends RigidBody
class_name Player

var heading = 1
var speed = 6
var steeringSpeed = 0

# maximums
const maxSpeed = 18
const maxTurning = 14

# previous speeds used for collisions
var previousSpeed = 0
var previousSteeringSpeed = 0

func _ready():
    pass


func _process(delta):

    # update previous
    previousSpeed = speed
    previousSteeringSpeed = steeringSpeed


    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    # update speed
    speed += speedInput * delta * 9
    speed = clamp(speed, 0, maxSpeed)

    # update steering
    steeringSpeed += steerInput * delta * 28
    steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)
    steeringSpeed = move_toward(steeringSpeed, 0, delta * 12)

    # bounce from the rails
    var posX = get_global_transform().origin.x
    if abs(posX) > 15:
        steeringSpeed *= -sign(posX) * sign(steeringSpeed) * .95

        if speed > 8:
            speed -= 2

        # TODO: particles



func _physics_process(delta):
    # move the vehicle body
    translate(delta * Vector3(steeringSpeed * speed / 20, 0, -speed))

    # rotate the modal according to the steering
    if $model != null:
        $model.rotation.y = -steeringSpeed / 30




func _on_player_body_entered(body):
    # called when the player collides with another one

    if 'heading' in body and 'previousSpeed' in body:
        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading
        var diff = otherSpeed - ourSpeed

        # update speed, lower effect on the player
        speed += heading * diff * .4


    if 'previousSteeringSpeed' in body:
        var diff = body.previousSteeringSpeed - previousSteeringSpeed

        # update steering, lower effect on the player
        steeringSpeed += diff * .7

