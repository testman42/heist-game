extends CSGBox3D
class_name CarHeadlight

# Handles the headlight breaking.

@export var inactiveMaterial: Material
@export var activeMaterial: Material

var isBroken := false


func breakOff() -> void:
    isBroken = true
    material = inactiveMaterial

    # propagate to nested turn signal, if any
    var turn = get_node_or_null('turn')
    if turn != null: turn.breakOff()

    # TODO: particles of light shattering
