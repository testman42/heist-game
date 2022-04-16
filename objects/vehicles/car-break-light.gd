extends CSGBox

export(SpatialMaterial) var activeMaterial
onready var bulb = get_node_or_null('bulb')

func _ready():
    assert(activeMaterial, 'Missing car breaking light active material')

    if GameSettings.quality <= 0:
        call_deferred('set_script', null)

        if bulb:
            bulb.queue_free()

func _on_car_startBreaking():
    material_override = activeMaterial
    if bulb: bulb.visible = true


func _on_car_stopBreaking():
    material_override = null
    if bulb: bulb.visible = false
