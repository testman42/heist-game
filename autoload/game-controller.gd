extends Node

export var bankAccount = 0

func switchToScene(scene: String):
    get_tree().change_scene('scenes/' + scene + '.tscn')
    LevelProgress.call_deferred('_onSceneChange')

func levelComplete():
    # TODO
    bankAccount += LevelProgress.money
    switchToScene('garage')

