extends Spatial

var inMenu = false

# Turns on only at night.
# TODO: turn on only in night levels
func _ready():
    queue_free()

func _process(_delta):
    process()

func process():
    if 'material' in get_parent():
        if visible:
            get_parent().material.emission_energy = 4
        else:
            get_parent().material.emission_energy = 1.5
