extends Spatial

var inMenu = false

# Turns on only at night.
func _ready():
    inMenu = get_node('/root/main-menu')
    process()

    if not GameController.nightMode and not inMenu:
        queue_free()

func _process(_delta):
    process()

func process():
    visible = GameController.nightMode

    if 'material' in get_parent():
        if visible:
            get_parent().material.emission_energy = 4
        else:
            get_parent().material.emission_energy = 1.5
