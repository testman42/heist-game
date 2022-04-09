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


func _on_car_body_entered(body):
    # delegate to the parent logic
    ._on_car_body_entered(body)

    # Here just calculate the money lost from the collision.
    # TODO: utilize Car's collision signal

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


func destroyPlayer():
    call_deferred('set_script', null)

    # TODO: implement changing the node to rigid body

    # swap the kinetic body mode for rigid body
    #mode = MODE_RIGID

    # add the ground collision mask
    set_collision_mask_bit(11, true)

    # add force according to the current movement, and a random rotation
    #apply_impulse(Vector3.ZERO, Vector3(steering, 0, speed * -heading))

    var amount = 10
    #apply_torque_impulse(Vector3(rand_range(-amount, amount), rand_range(-amount, amount), rand_range(-amount, amount)))

    # turn into a wreck
    get_node('model/wheels').queue_free()
    get_node('model/height-adjust/lights').queue_free()

    var parts = get_node('model/height-adjust').get_children()
    for part in parts:
        if 'material' in part:
            part.material = wreckMaterial
