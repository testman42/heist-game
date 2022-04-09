extends CSGBox

onready var bulb = get_node_or_null('bulb')

func _ready():
    if not GameController.lights:
        call_deferred('set_script', null)

        if bulb:
            bulb.queue_free()
    else:
        material = material.duplicate()
        material.emission_energy = 1

func _on_car_startBreaking():
    material.emission_energy = 4
    if bulb:
        bulb.visible = true


func _on_car_stopBreaking():
    material.emission_energy = 1.5
    if bulb:
        bulb.visible = false
