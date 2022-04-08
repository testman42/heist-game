extends RigidBody
class_name Player

export(SpatialMaterial) var wreckMaterial

signal player_moved
signal player_collision

var heading = 1
var speed = 6
var steeringSpeed = 0

# maximums
const maxSpeed = 18
const maxTurning = 18

# previous speeds used for collisions
var previousSpeed = 0
var previousSteeringSpeed = 0

func _ready():
    pass


func _process(delta):


    var posX = transform.origin.x

    # update previous
    previousSpeed = speed
    previousSteeringSpeed = steeringSpeed


    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    # update speed
    if abs(speed) < maxSpeed:
        speed += speedInput * delta * 9
        speed = max(0, speed)
    else:
        speed = move_toward(speed, 0, delta * 4)

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


    # bounce from the rails
    if abs(posX) > 15:
        steeringSpeed *= -sign(posX) * sign(steeringSpeed) * .95
        emit_signal('player_collision', abs(steeringSpeed) / 26)

        if speed > 8:
            speed -= 2




func _physics_process(delta):
    # move the vehicle body
    translate(delta * Vector3(steeringSpeed * speed / 20, 0, -speed))
    emit_signal('player_moved', delta * speed)

    # rotate the modal according to the steering
    if $model != null:
        $model.rotation.y = -steeringSpeed / 30




func _on_player_body_entered(body):
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

        # update speed, lower effect on the player
        if abs(diffPos.x) < 1.2:
            speed += heading * diff * .4
            amount += abs(diff)

        # update steering, lower effect on the player
        steeringSpeed += diffSteering * .7
        amount += abs(diffSteering / 6)


        # ensure some minimum diff is applied to make the cars
        # bounce from each other and not "merge" into one - see #2
        if abs(diff) < 4:
            speed += heading * sign(diff) * 1.5
        if abs(diffSteering) < 4:
            steeringSpeed += sign(diffSteering) * 1.5

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



