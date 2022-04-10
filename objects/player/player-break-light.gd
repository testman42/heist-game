extends CSGBox

export(SpatialMaterial) var activeMaterial
onready var bulb = get_node_or_null('bulb')

func _ready():
    assert(activeMaterial, 'Missing player breaking light active material')

    if not GameController.lights:
        call_deferred('set_script', null)

        if bulb:
            bulb.queue_free()

func _process(_delta):
    if Input.get_action_strength('break') > .1:
        material_override = activeMaterial
        if bulb: bulb.visible = true
    else:
        material_override = null
        if bulb: bulb.visible = false
