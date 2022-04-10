extends Car
class_name Player


export var ignoreInput = false

signal player_moved
signal player_collision


func _process(delta):

    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    if ignoreInput:
        steerInput = 0
        speedInput = 0

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


func _physics_process(delta):
    emit_signal('player_moved', delta * speed)


func onCollided(body, normal):

    # Here just calculate the money lost from the collision.

    var amount = 0
    var diffPos = body.transform.origin - transform.origin

    if 'heading' in body and 'previousSpeed' in body and 'previousSteering' in body:

        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading
        var otherSteering = body.previousSteering * body.heading
        var ourSteering = previousSteering * heading

        var diff = otherSpeed - ourSpeed
        var diffSteering = otherSteering - ourSteering

        if abs(diffPos.x) < 1.2:
            amount += abs(diff)

        amount += abs(diffSteering / 6)


    # amount is roughly 10-30
    emit_signal('player_collision', amount)


