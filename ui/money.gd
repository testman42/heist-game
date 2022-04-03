extends Control

func _process(_delta):
    $text.text = str(max(0, round(LevelProgress.money)))
