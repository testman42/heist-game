extends Car
class_name PoliceCar

# AI for the police! This class makes the police car follow the player
# and occasionally bump into it. I wrote the base of this AI code during
# the original Ludum Dare!


# used to position the police car next to the player on either
# side while the police is chasing
@onready var finalPos: float = randf_range(2, 4) * [-1, 1].pick_random()


func _process(delta: float):
    super(delta)

    var player := get_tree().get_first_node_in_group('player') as Player
    if player == null: return

    # disable the AI when spinning or destroyed
    if isSpinning or isDestroyed:
        setBreaking(false)
        return


    if 'speed' in player and player.speed > 0:
        chasePlayer(delta, player)
    else:
        stopNearPlayer(delta, player)


func chasePlayer(delta: float, player: Player):

    var diff := global_position - player.global_position

    # handle speed to get near the player
    if diff.z > 0:
        if speed < maxSpeed:
            setBreaking(false)
            speed += delta * lerpf(acceleration / 4.0, acceleration, clampf(diff.z / 4.0, 0, 1))


    # when in front of the player, try to maintain half the speed of the player
    elif speed > player.speed / 2:
        setBreaking(true)
        speed -= breakingForce * delta

    else:
        setBreaking(false)
        # TODO: is it a good idea to keep accelerating here?
        # speed += delta * acceleration / 4


    # steer next to the player until we are in line, then hit them
    var targetX := player.global_position.x
    var ramming := true

    if absf(diff.z) > 1 and absf(diff.z) < 3:
        targetX += finalPos
    if absf(diff.z) > 1:
        ramming = false

    var total := targetX - global_position.x
    var absTotal := absf(total)

    # try steering towards the target
    if ramming:
        if absf(steering) < maxSteering:
            steering += steeringForce * delta * signf(total)

    elif absTotal > 2:
        if absf(steering) < absTotal and absf(steering) < maxSteering:
            steering += steeringForce * delta * signf(total)

    elif absTotal > .1:
        steering += delta * signf(total) * lerpf(0, steeringForce, absTotal / 2)


func stopNearPlayer(delta: float, player: Player):

    var diff := global_position - player.global_position

    # handle speed to get near the player
    if diff.z > .5 and speed < 6:
        setBreaking(false)
        speed += delta * acceleration * .4

    else:
        setBreaking(true)
        speed = move_toward(speed, 0, breakingForce * delta)


    # steer next to the player
    var targetX := player.global_position.x + finalPos
    var total := targetX - global_position.x
    var absTotal := absf(total)

    # try steering towards the target
    if absf(steering) > absTotal * 2:
        steering -= steeringForce * delta * signf(total)

    elif absTotal > .1 and abs(steering) < maxSteering:
        steering += steeringForce * delta * signf(total)
