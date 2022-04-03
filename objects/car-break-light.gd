extends CSGBox

onready var car := get_node('../../../..') as Car
var previousSpeed = 0

func _ready():
    material = material.duplicate()

func _process(_delta):
    if not car or not $bulb:
        return

    var speed = abs(car.speed)

    if speed < previousSpeed - .02 or speed < .1:
        $bulb.visible = true
        material.emission_energy = 2
    else:
        $bulb.visible = false
        material.emission_energy = .2


    previousSpeed = speed

