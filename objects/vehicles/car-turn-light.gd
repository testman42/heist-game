extends CSGBox

export(SpatialMaterial) var activeMaterial
onready var bulb = get_node_or_null('bulb')
var active = false
var timer = 0

func _ready():
    assert(activeMaterial, 'Missing car turn light active material')

    if GameSettings.quality <= 0:
        call_deferred('set_script', null)

        if bulb:
            bulb.queue_free()


func _process(_delta):
    if not active:
        material_override = null
        if bulb: bulb.visible = false
        return

    var time = OS.get_ticks_msec() - timer
    var value = sin(time / 200)

    if value > 0:
        material_override = activeMaterial
        if bulb: bulb.visible = true
    else:
        material_override = null
        if bulb: bulb.visible = false


func start():
    active = true
    timer = OS.get_ticks_msec()


func stop():
    active = false


func _on_car_collided(_collider, _normal):
    stop()

