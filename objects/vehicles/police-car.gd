extends Car
class_name PoliceCar

# AI for the police! Typing this on the second day of the game jam at 19:58
# so expect weird code and shortcuts. Anyway, this class makes the police car
# follow the player and occasionally bump into it.


var acceleration = rand_range(10, 16)
var breaking = 8

var finalPos = rand_range(3, 6)


func _ready():
    if randf() < .5:
        finalPos *= -1

    if heading < 0:
        queue_free()


func _process(delta):
    # #safety - ignore if the player does not exist
    if not player or not is_instance_valid(player):
        return

    # disable the AI when spinning
    if spinning:
        setBreaking(false)
        return


    if 'speed' in player:
        ChasePlayer(delta)
    else:
        StopNearPlayer(delta)





func ChasePlayer(delta):

    var diff := transform.origin - player.transform.origin

    # handle speed to get near the player
    if diff.z > 0:
        if speed < maxSpeed:
            setBreaking(false)
            speed += delta * lerp(acceleration / 3, acceleration, clamp(diff.z / 4, 0, 1))

    elif speed > player.speed / 2:
        setBreaking(true)
        speed -= breaking * delta

    else:
        setBreaking(false)
        speed += delta * acceleration / 4



    # steer next to the player until we are in line, then hit them
    var targetX = player.transform.origin.x
    var ramming = true
    if diff.z > 1:
        targetX += finalPos
        ramming = false

    var total = targetX - transform.origin.x
    var absTotal = abs(total)

    # try steering towards the target
    if ramming:
        if abs(steeringSpeed) < maxTurning:
            steeringSpeed += 22 * delta * sign(total)

    elif absTotal > 2:
        if abs(steeringSpeed) < absTotal:
            steeringSpeed += 16 * delta * sign(total)

    elif absTotal > .2:
        steeringSpeed += 10 * delta * sign(total)




func StopNearPlayer(delta):

    var diff := transform.origin - player.transform.origin

    # handle speed to get near the player
    if diff.z > .5 and speed < 6:
        setBreaking(false)
        speed += delta * acceleration * .4

    else:
        setBreaking(true)
        speed = move_toward(speed, 0, breaking * delta)


    # try to avoid cars in front
    if $front/raycast1.is_colliding():
        steeringSpeed += 34 * delta
    elif $front/raycast2.is_colliding():
        steeringSpeed -= 34 * delta


    # steer next to the player until we are in line, then hit them
    var targetX = player.transform.origin.x + finalPos
    var total = targetX - transform.origin.x
    var absTotal = abs(total)

    # try steering towards the target
    var force = 22

    if absTotal > 2:
        if abs(steeringSpeed) < absTotal:
            steeringSpeed += force * delta * sign(total)

    elif absTotal > .2:
        steeringSpeed += force * .4 * delta * sign(total)



