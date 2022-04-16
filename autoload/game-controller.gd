extends Node


func _ready():
    randomize()



func switchToScene(scene: String):
    get_tree().change_scene('scenes/' + scene + '.tscn')
    LevelProgress.call_deferred('_onSceneChange')

func levelComplete():
    # TODO
    switchToScene('outro')
