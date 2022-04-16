extends CSGBox
class_name BlinkingLight

onready var offset = randf() * 10
onready var bulb = get_node_or_null('bulb')

func _ready():
    material = material.duplicate()
    if GameSettings.quality <= 0 and bulb:
        bulb.queue_free()

func _process(_delta):
    var value = sin(OS.get_ticks_msec() / 50.0 + offset) / 2 + .5
    material.emission_energy = value * 10
