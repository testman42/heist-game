extends Node3D
class_name Breakable

# Breakable car part. When broken, it detaches itself from
# the car and becomes a separate physics object.

func breakOff():

    var newNode := DynamicObject.new()

    newNode.collision_layer = 0
    newNode.set_collision_layer_value(7, true)

    newNode.collision_mask = 0
    for i in range(1, 8):
        newNode.set_collision_mask_value(i, true)

    # position the new object
    newNode.transform = global_transform

    # add force according to the current movement, and a random rotation
    # TODO: newNode.apply_impulse(Vector3(steering, 0, speed * -heading))

    # TODO: newNode.apply_torque_impulse(Vector3(
    #     0,
    #     clamp(speed, -CarConstants.spinningSpeedClamp, CarConstants.spinningSpeedClamp) * CarConstants.spinningRotation * spinningDirection,
    #     0
    # ))

    # move child nodes over
    for child in get_children():
        remove_child(child)
        newNode.add_child(child)

    get_tree().root.add_child(newNode)
    queue_free()
