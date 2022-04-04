extends Car
class_name CarLogic

# Extends from Car and handles car acceleration, breaking, crash state, etc.
# Basically an AI for cars to make them much better than just moving
# by a constant speed all the time.

onready var currentLane = transform.origin.x
onready var previousLane = transform.origin.x

const lanes = [1.5, 5, 8.5]

func _process(delta):
    SpeedAdjust(delta)
    HandleLane(delta)


func SpeedAdjust(delta):

    if spinning:
        setBreaking(false)
        for raycast in [$front/raycast1, $front/raycast2]:
            raycast.enabled = false
        return

    # handle special condition - when the player hits the car and it gets into reverse
    if speed < 0:
        # try to slow down
        speed += 6 * delta
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
                # TODO
                distance += other.speed - speed

            # slow down
            speed = move_toward(speed, 0, delta * lerp(8, 0, distance / 8))
            setBreaking(true)

            return


    # nothing in front, speed up
    setBreaking(false)
    if speed < maxSpeed:
        speed += delta * 8


func HandleLane(delta):

    if spinning:
        return

    # ignore for cars going in the opposite direction
    if heading < 0:
        return

    # TODO: these are just some hard-coded values which should be in the editor but there's no time...
    if not is_equal_approx(currentLane, previousLane):
        if abs(transform.origin.x - currentLane) < .1:
            # done
            previousLane = currentLane

    # randomly choose to change the lane
    elif randf() < .0012:
        currentLane = lanes[randi() % lanes.size()] * heading


    var total = currentLane - transform.origin.x
    var absTotal = abs(total)

    # try steering towards the lane
    if absTotal > 2:
        if abs(steeringSpeed) < absTotal:
            steeringSpeed += 21 * delta * sign(total)

    elif absTotal > .2:
        steeringSpeed += 11 * delta * sign(total)

