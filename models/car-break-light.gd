extends CSGBox

onready var car := get_node('../../../..') as Car
var previousSpeed = 0

func _ready():
	assert(car != null, 'Cannot find Car in its breaking lights')
	material = material.duplicate()

func _process(_delta):
    if not $bulb:
        return

    var speed = abs(car.speed)

    if speed < previousSpeed - .05:
        $bulb.visible = true
        material.emission_energy = 2
    else:
        $bulb.visible = false
        material.emission_energy = .2


    previousSpeed = speed

