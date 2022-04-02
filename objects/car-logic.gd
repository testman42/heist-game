extends Car
class_name CarLogic

# Extends from Car and handles car acceleration, breaking, crash state, etc.
# Basically an AI for cars to make them much better than just moving
# by a constant speed all the time.

func _process(delta):

    # handle special condition - when the player hits the car and it gets into reverse
    if speed < 0:
        # try to slow down
        speed += 6 * delta
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
            speed -= delta * lerp(8, 0, distance / 8)
            # prevent the car from reversing
            speed = max(0, speed)

            return


    # nothing in front, speed up
    if speed < maxSpeed:
        speed += delta * 8


