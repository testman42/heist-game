extends CSGBox

onready var car := get_node('../../../..') as Car

func _ready():
	assert(car != null, 'Cannot find Car in its breaking lights')
	material = material.duplicate()

func _process(_delta):
    if not $bulb:
        return

    if abs(car.speed) < abs(car.previousSpeed) - .02 or abs(car.speed) < .01:
        $bulb.visible = true
        material.emission_energy = 2
    else:
        $bulb.visible = false
        material.emission_energy = .2

