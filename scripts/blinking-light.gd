extends CSGBox
class_name BlinkingLight

onready var offset = randf() * 10

func _ready():
    material = material.duplicate()

func _process(_delta):
    var value = sin(OS.get_ticks_msec() / 50.0 + offset) / 2 + .5

    material.emission_energy = value * 15
    if $bulb:
        $bulb.light_energy = value * 15

