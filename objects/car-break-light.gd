extends CSGBox

var previousSpeed = 0

func _ready():
    if not GameController.lights:
        queue_free()
    else:
        material = material.duplicate()

func _process(_delta):
    var car := get_node('../../../..') as Car
    if not car or car.spinning:
        $bulb.visible = false
        material.emission_energy = 1.5
        return

    var speed = abs(car.speed)

    if speed < previousSpeed - .04 or speed < .1:
        $bulb.visible = true
        material.emission_energy = 5
    else:
        $bulb.visible = false
        material.emission_energy = 1.5


    previousSpeed = speed

