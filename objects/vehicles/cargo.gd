extends Node3D

# Ejects itself into the air when the car that
# is carrying this cargo collides with anything.

@export var cargoProp: PackedScene


func eject() -> void:

    var newNode := cargoProp.instantiate() as RigidBody3D

    newNode.transform = global_transform

    # move over all children
    for child in get_children():
        child.reparent(newNode, false)

    get_tree().root.add_child(newNode)
    queue_free()

    # apply upwards force to launch it from the vehicle
    newNode.apply_impulse(Vector3.UP * 7.0)
