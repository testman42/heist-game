extends CSGBox

func _ready():
    material = material.duplicate()

func _process(_delta):
    if not $bulb:
        return

    if Input.get_action_strength('break') > .1:
        $bulb.visible = true
        material.emission_energy = 5
    else:
        $bulb.visible = false
        material.emission_energy = 1.5


