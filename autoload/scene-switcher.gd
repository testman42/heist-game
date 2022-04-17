extends Node

signal sceneSwitched(name)


func switchToScene(scene: String):
    get_tree().change_scene('scenes/' + scene + '.tscn')
    emit_signal('sceneSwitched', scene)
