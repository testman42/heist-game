extends Car
class_name Player

# Player-controlled car. This car is always in the middle of the camera,
# has the "player" group, and other objects in game are spawned and deleted
# using the player's position.


func _process(delta):

    super(delta)

    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    # update speed
    if speed < maxSpeed:
        speed += speedInput * acceleration * delta

        # the player can never go backwards
        speed = max(0, speed)

    # slow down a little when not accelerating
    if is_equal_approx(speedInput, 0):
        speed = move_toward(speed, 0, idleSlowing * delta)

    # update steering
    if abs(steering) < maxSteering:
        if is_equal_approx(steerInput, 0):
            steering = move_toward(steering, 0, delta * 12)
        else:
            var force = steeringForce
            if sign(steerInput) != sign(steering):
                force *= 1.4

            steering += steerInput * delta * force
