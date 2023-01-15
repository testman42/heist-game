extends CSGBox3D
class_name CarBreakLight

# Handles the break light turning on and off.
# BUG: for some reason, material_override does not work. I have
# to save the original material and toggle that.

@export var inactiveMaterial: Material
@export var halfActiveMaterial: Material
@export var activeMaterial: Material

var isShining := false
var isBroken := false


func start() -> void:
    if isBroken: return

    isShining = true
    material = activeMaterial
    $bulb.visible = true

func stop() -> void:
    if isBroken: return

    isShining = false
    material = halfActiveMaterial
    $bulb.visible = false

func breakOff() -> void:
    stop()

    isBroken = true
    material = inactiveMaterial

    # propagate to nested turn signal, if any
    var turn = get_node_or_null('turn')
    if turn != null: turn.breakOff()

    # TODO: particles of light shattering
