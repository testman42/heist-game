extends Node

var nightMode = false

var trees = true
var lights = true
var particles = false

var traffic = true
var police = true

func _ready():
    randomize()



func switchToScene(scene: String):
    get_tree().change_scene('scenes/' + scene + '.tscn')
    LevelProgress.call_deferred('_onSceneChange')

func levelComplete():
    # TODO
    switchToScene('outro')


func _onNightModeToggled(value):
    nightMode = value
func _onTreesToggled(value):
    trees = value
func _onLightsToggled(value):
    lights = value
func _onParticlesToggled(value):
    particles = value

func _onTrafficToggled(value):
    traffic = value
func _onPoliceToggled(value):
    police = value
