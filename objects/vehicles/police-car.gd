extends Car
class_name PoliceCar

# AI for the police! Typing this on the second day of the game jam at 19:58
# so expect weird code and shortcuts. Anyway, this class makes the police car
# follow the player and occasionally bump into it.

var finalPos = rand_range(3, 6)


func _ready():
    $front.queue_free()

    if randf() < .5:
        finalPos *= -1

    if heading < 0:
        queue_free()


func _process(delta):
    if not player or not is_instance_valid(player):
        return

    # disable the AI when spinning
    if isSpinning:
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
            speed += delta * lerp(acceleration / 4, acceleration, clamp(diff.z / 4, 0, 1))


    # when in front of the player, try to maintain half the speed of the player
    elif speed > player.speed / 2:
        setBreaking(true)
        speed -= breakingForce * delta

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
        if abs(steering) < maxSteering:
            steering += steeringForce * delta * sign(total)

    elif absTotal > 2:
        if abs(steering) < absTotal and abs(steering) < maxSteering:
            steering += steeringForce * delta * sign(total)

    elif absTotal > .1:
        steering += delta * sign(total) * lerp(0, steeringForce, absTotal / 2)


func StopNearPlayer(delta):

    var diff := transform.origin - player.transform.origin

    # handle speed to get near the player
    if diff.z > .5 and speed < 6:
        setBreaking(false)
        speed += delta * acceleration * .4

    else:
        setBreaking(true)
        speed = move_toward(speed, 0, breakingForce * delta)


    # steer next to the player until we are in line, then hit them
    var targetX = player.transform.origin.x + finalPos
    var total = targetX - transform.origin.x
    var absTotal = abs(total)

    # try steering towards the target
    if abs(steering) > absTotal * 2:
        steering -= steeringForce * delta * sign(total)

    elif absTotal > .1 and abs(steering) < maxSteering:
        steering += steeringForce * delta * sign(total)

