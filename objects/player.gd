extends RigidBody
class_name Player

signal player_moved
signal player_collision

var heading = 1
var speed = 6
var steeringSpeed = 0

# maximums
const maxSpeed = 18
const maxTurning = 14

# previous speeds used for collisions
var previousSpeed = 0
var previousSteeringSpeed = 0

func _ready():
    pass


func _process(delta):

    # update previous
    previousSpeed = speed
    previousSteeringSpeed = steeringSpeed


    var steerInput = Input.get_axis('move_left', 'move_right')
    var speedInput = Input.get_axis('break', 'accelerate')

    # update speed
    speed += speedInput * delta * 9
    speed = clamp(speed, 0, maxSpeed)

    # update steering
    steeringSpeed += steerInput * delta * 28
    steeringSpeed = clamp(steeringSpeed, -maxTurning, maxTurning)
    steeringSpeed = move_toward(steeringSpeed, 0, delta * 12)

    # bounce from the rails
    var posX = get_global_transform().origin.x
    if abs(posX) > 15:
        steeringSpeed *= -sign(posX) * sign(steeringSpeed) * .95
        emit_signal('player_collision', abs(steeringSpeed) / 10)

        if speed > 8:
            speed -= 2

        var transform = Transform(global_transform)
        transform.origin.x += -sign(steeringSpeed) * 1.2
        ParticleEffect.spawnCollisionSparks(transform, 10, Vector3(-steeringSpeed, 0, -speed))



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

    if 'heading' in body and 'previousSpeed' in body:
        var otherSpeed = body.previousSpeed * body.heading
        var ourSpeed = previousSpeed * heading
        var diff = otherSpeed - ourSpeed

        # update speed, lower effect on the player
        speed += heading * diff * .4
        amount += abs(diff)


    if 'previousSteeringSpeed' in body:
        var diff = body.previousSteeringSpeed - previousSteeringSpeed

        # update steering, lower effect on the player
        steeringSpeed += diff * .7
        amount += abs(diff)

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

    # particles
    ParticleEffect.spawnExplosion(global_transform)

    # turn into a wreck
    get_node('model/wheels').queue_free()
    get_node('model/height-adjust/lights').queue_free()

    var parts = get_node('model/height-adjust').get_children()
    for part in parts:
        if not 'material' in part:
            continue

        part.material = part.material.duplicate()
        part.material.albedo_color = Color(.1, .1, .1)



