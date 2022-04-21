extends Control

func _process(_delta):
    $progressbar.max_value = LevelProgress.targetDistance
    $progressbar.value = LevelProgress.distance
