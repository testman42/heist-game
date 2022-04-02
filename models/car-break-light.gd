extends CSGBox

onready var car := get_node('../../../..') as Car
var previousSpeed = 0

func _ready():
    assert(car, 'Cannot find Car in its breaking lights')
    assert($bulb, 'Missing car breaking bulb')
    material = material.duplicate()

func _process(_delta):
    var speed = abs(car.speed)

    if speed < previousSpeed - .02 or speed < .1:
        $bulb.visible = true
        material.emission_energy = 2
    else:
        $bulb.visible = false
        material.emission_energy = .2


    previousSpeed = speed

