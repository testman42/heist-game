extends CSGBox3D
class_name CarTurnSignal

# Handles the blinking of turn signals using a simple timer.
# BUG: for some reason, material_override does not work. I have
# to save the original material and toggle that.

@export var inactiveMaterial: Material
@export var activeMaterial: Material

var isBlinking := false


func start() -> void:
    isBlinking = true
    material = activeMaterial
    $bulb.visible = true

func stop() -> void:
    isBlinking = false
    material = inactiveMaterial
    $bulb.visible = false


func _on_timer_timeout() -> void:
    if not isBlinking: return

    if material == inactiveMaterial:
        material = activeMaterial
        $bulb.visible = true
    else:
        material = inactiveMaterial
        $bulb.visible = false
