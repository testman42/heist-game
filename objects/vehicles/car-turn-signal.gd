extends CSGBox3D
class_name CarTurnSignal

# Handles the blinking of turn signals using a simple timer.
# BUG: for some reason, material_override does not work. I have
# to save the original material and toggle that.

@export var inactiveMaterial: Material
@export var activeMaterial: Material

var isBlinking := false
var isBroken := false


func start() -> void:
    if isBroken: return

    isBlinking = true
    material = activeMaterial
    $bulb.visible = true

func stop() -> void:
    if isBroken: return

    isBlinking = false
    material = inactiveMaterial
    $bulb.visible = false

func breakOff() -> void:
    stop()
    isBroken = true

    # TODO: particles of light shattering


func _on_timer_timeout() -> void:
    if not isBlinking: return
    if isBroken: return

    if material == inactiveMaterial:
        material = activeMaterial
        $bulb.visible = true
    else:
        material = inactiveMaterial
        $bulb.visible = false
