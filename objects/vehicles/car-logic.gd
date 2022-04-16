extends Car
class_name CarLogic

# Handles the logic of cars in traffic. They maintain speed, break
# if there's anything in front, and change lanes.

signal startTurningLeft
signal startTurningRight
signal stopTurning

onready var currentLane = transform.origin.x
onready var previousLane = transform.origin.x


func _process(delta):
    SpeedAdjust(delta)
    HandleLane(delta)


func SpeedAdjust(delta):

    if isSpinning:
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

            var breakStrength

            if "speed" in other:
                var speedDiff = speed - other.speed
                breakStrength = lerp(0, breakingForce, clamp(speedDiff / 8, 0, 1))

                if distance < 3:
                    breakStrength = breakingForce
            else:
                breakStrength = lerp(breakingForce, 0, clamp(distance / 8, 0, 1))

            # slow down
            speed = move_toward(speed, 0, delta * breakStrength)

            setBreaking(breakStrength > .2)

            return


    # nothing in front, speed up
    setBreaking(false)
    if speed < maxSpeed:
        speed += delta * acceleration


func HandleLane(delta):

    if isSpinning:
        return

    if abs(transform.origin.x - currentLane) < CarConstants.laneMatchThreshold:
        if not is_equal_approx(currentLane, previousLane):
                # done changing lanes
                previousLane = currentLane
                emit_signal('stopTurning')

        # randomly choose to change the lane
        elif randf() < CarConstants.chanceToChangeLane:

            # choose any lane except the current one
            while is_equal_approx(currentLane, previousLane):
                currentLane = HighwayConstants.lanes[randi() % HighwayConstants.lanes.size()] * heading

            if currentLane > previousLane:
                if heading > 0: emit_signal('startTurningRight')
                else: emit_signal('startTurningLeft')
            else:
                if heading > 0: emit_signal('startTurningLeft')
                else: emit_signal('startTurningRight')


    var total = currentLane - transform.origin.x
    var absTotal = abs(total)

    # try steering towards the lane
    if (total > 0 and steering > total) or (total < 0 and steering < total):
        steering -= steeringForce * delta * sign(total)

    elif absTotal > CarConstants.laneMatchThreshold and abs(steering) < maxSteering:
        steering += steeringForce * delta * sign(total)
