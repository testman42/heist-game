extends Car
class_name Player


export var ignoreInput = false

signal player_moved
signal player_collision


func _process(delta):


    var posX = transform.origin.x


    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    if ignoreInput:
        steerInput = 0
        speedInput = 0

    # update speed
    if abs(speed) < maxSpeed:
        speed += speedInput * delta * 9
        speed = max(0, speed)

    # slow down a little when not accelerating
    if is_equal_approx(speedInput, 0):
        speed = move_toward(speed, 0, 1.2 * delta)

    # slow down if on the grass
    if abs(posX) > 11:
        speed = move_toward(speed, 0, 8 * delta)

    # update steering
    if abs(steeringSpeed) < maxTurning:
        if is_equal_approx(steerInput, 0):
            steeringSpeed = move_toward(steeringSpeed, 0, delta * 12)
        else:
            var force = 22
            if sign(steerInput) != sign(steeringSpeed):
                force = 40

            steeringSpeed += steerInput * delta * force
    else:
        steeringSpeed = move_toward(steeringSpeed, 0, delta * 22)





func _physics_process(delta):
    emit_signal('player_moved', delta * speed)




func _on_car_body_entered(body):
    ._on_car_body_entered(body)
    # called when the player collides with another one

    var amount = 0
    var diffPos = body.transform.origin - transform.origin

    if 'heading' in body and 'previousSpeed' in body and 'previousSteeringSpeed' in body:

        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading
        var otherSteering = body.previousSteeringSpeed * body.heading
        var ourSteering = previousSteeringSpeed * heading

        var diff = otherSpeed - ourSpeed
        var diffSteering = otherSteering - ourSteering

        if abs(diffPos.x) < 1.2:
            amount += abs(diff)

        amount += abs(diffSteering / 6)


    # amount is roughly 10-30
    emit_signal('player_collision', amount)


func destroyPlayer():
    call_deferred('set_script', null)

    # disable collision reporting
    disconnect('body_entered', self, '_on_player_body_entered')
    contact_monitor = false

    # swap the kinetic body mode for rigid body
    mode = MODE_RIGID

    # add the ground collision mask
    collision_mask |= 1 << 11

    # add force according to the current movement, and a random rotation
    apply_impulse(Vector3.ZERO, Vector3(steeringSpeed, 0, speed * -heading))

    var amount = 10
    apply_torque_impulse(Vector3(rand_range(-amount, amount), rand_range(-amount, amount), rand_range(-amount, amount)))


    # turn into a wreck
    get_node('model/wheels').queue_free()
    get_node('model/height-adjust/lights').queue_free()

    var parts = get_node('model/height-adjust').get_children()
    for part in parts:
        if 'material' in part:
            part.material = wreckMaterial
