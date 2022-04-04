extends CSGBox


func _ready():
    if not GameController.lights:
        call_deferred('set_script', null)

        if $light:
            $light.queue_free()
    else:
        material = material.duplicate()
        material.emission_energy = 1

func _on_car_startBreaking():
    material.emission_energy = 4
    if $light:
        $light.visible = true


func _on_car_stopBreaking():
    material.emission_energy = 1.5
    if $light:
        $light.visible = false
