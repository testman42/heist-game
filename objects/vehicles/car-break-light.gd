extends CSGBox3D
class_name CarBreakLight

# Handles the break light turning on and off.
# BUG: for some reason, material_override does not work. I have
# to save the original material and toggle that.

@export var inactiveMaterial: Material
@export var activeMaterial: Material

var isShining := false


func start() -> void:
    isShining = true
    material = activeMaterial

func stop() -> void:
    isShining = false
    material = inactiveMaterial
