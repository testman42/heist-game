extends Car
class_name CarLogic

# Handles the logic of cars in traffic. They maintain speed, break
# if there's anything in front, and change lanes.

onready var currentLane = transform.origin.x
onready var previousLane = transform.origin.x

const lanes = [1.5, 5, 8.5]

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

            if "speed" in other:
                distance += other.speed - speed

            # slow down
            var breakStrength = lerp(breakingForce, 0, clamp(distance / 8, 0, 1))
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

    # ignore for cars going in the opposite direction, they don't change lanes
    if heading < 0:
        return

    # TODO: these are just some hard-coded values which should be in the editor but there's no time...
    if not is_equal_approx(currentLane, previousLane):
        if abs(transform.origin.x - currentLane) < .1:
            # done changing lanes
            previousLane = currentLane

    # randomly choose to change the lane
    elif randf() < .012:
        currentLane = lanes[randi() % lanes.size()] * heading


    var total = currentLane - transform.origin.x
    var absTotal = abs(total)

    # try steering towards the lane
    if abs(steering) > absTotal * 2:
        steering -= steeringForce * delta * sign(total)

    elif absTotal > .1 and abs(steering) < maxSteering:
        steering += steeringForce * delta * sign(total)

