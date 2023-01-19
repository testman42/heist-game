extends Car
class_name CarLogic

# Handles the logic of cars in traffic. They maintain speed, break
# if there's anything in front, and change lanes. Nothing fancy, just a lot
# of potential for major car accidents.

signal startTurningLeft
signal startTurningRight
signal stopTurning

# What lane the car is in. Lane closest to the center is 0, the next is 1, etc.
# previousLane is used for turn signals and knowing when switching lanes is done.
@export var currentLane := 0
@export var previousLane := 0


func _process(delta: float):
    super(delta)

    SpeedAdjust(delta)
    HandleLane(delta)


func SpeedAdjust(delta: float):

    if isSpinning or isDestroyed:
        setBreaking(false)
        for raycast in [$front/raycast1, $front/raycast2]:
            raycast.enabled = false
        return

    # handle special condition - when the player hits the car and it gets into reverse
    if speed < 0:
        # try to slow down
        speed += breakingForce * delta
        setBreaking(true)
        return

    # check the attached raycasts whether there's anything in front of us
    for raycast in [$front/raycast1, $front/raycast2]:

        if raycast.is_colliding():
            var point = raycast.get_collision_point()
            var distance = point.distance_to($front.get_global_transform().origin)

            var other = raycast.get_collider()
            if not other:
                continue

            var breakStrength: float

            if "speed" in other:
                var speedDiff = speed - other.speed
                if speedDiff < 0:
                    continue

                breakStrength = lerpf(0, breakingForce, clampf(speedDiff / 8, 0, 1))

                if distance < 2:
                    breakStrength = breakingForce
            else:
                breakStrength = lerpf(breakingForce, 0, clampf(distance / 8, 0, 1))

            # slow down
            speed = move_toward(speed, 0, delta * breakStrength)

            setBreaking(breakStrength > .2)

            return


    # nothing in front, speed up
    setBreaking(false)
    if speed < maxSpeed:
        speed += delta * acceleration


func HandleLane(delta: float):

    if isSpinning:
        return

    # get lanes from the current block
    var block := getCurrentBlock()
    var lanes: Array[NodePath]

    if heading > 0:
        lanes = block.positiveLanes
    else:
        lanes = block.negativeLanes


    if currentLane >= lanes.size():
        # our current lane no longer exists in this block, move to the center
        previousLane = currentLane
        currentLane = lanes.size() - 1

        if heading > 0: emit_signal('startTurningLeft')
        else: emit_signal('startTurningRight')

    # get the global X position of our current lane
    var lane := block.get_node(lanes[currentLane]) as Node3D
    assert(lane != null, 'Missing lane position')
    var currentLaneX = lane.global_position.x


    if absf(global_position.x - currentLaneX) < CarConstants.laneMatchThreshold:
        if not is_equal_approx(currentLane, previousLane):
            # done changing lanes
            previousLane = currentLane
            emit_signal('stopTurning')

        # randomly choose to change the lane
        elif randf() < CarConstants.chanceToChangeLane:

            # choose any lane except the current one
            while is_equal_approx(currentLane, previousLane):
                currentLane = randi() % lanes.size()

            if currentLane > previousLane:
                if heading > 0: emit_signal('startTurningRight')
                else: emit_signal('startTurningLeft')
            else:
                if heading > 0: emit_signal('startTurningLeft')
                else: emit_signal('startTurningRight')


    var total := currentLaneX - global_position.x
    var absTotal := absf(total)

    # try steering towards the lane
    if (total > 0 and steering > total) or (total < 0 and steering < total):
        steering -= steeringForce * delta * sign(total)

    elif absTotal > CarConstants.laneMatchThreshold and abs(steering) < maxSteering:
        steering += steeringForce * delta * sign(total)


# Finds the block the car is currently in.
func getCurrentBlock() -> Block:
    var blocks = get_tree().get_nodes_in_group('block')
    assert(blocks.size() > 0, 'No blocks in the scene')

    if global_position.z > blocks[0].global_position.z + HighwayConstants.blockLength / 2.0:
        # car is way back, use the first block
        return blocks[0]

    for block in blocks:
        if global_position.z <= block.global_position.z + HighwayConstants.blockLength / 2.0 and global_position.z >= block.global_position.z - HighwayConstants.blockLength / 2.0:
            return block

    # car is way in front, use the last block
    return blocks[-1]



