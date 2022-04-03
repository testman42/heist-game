extends Control

func _process(delta):
    $text.text = str(max(0, LevelProgress.money))
