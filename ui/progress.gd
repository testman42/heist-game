extends Control

func _process(_delta):
    $progressbar.max_value = LevelProgress.targetDistance
    $progressbar.value = LevelProgress.distance
    $icon.anchor_left = clamp(LevelProgress.distance / LevelProgress.targetDistance, 0, 1)
    $icon.anchor_left = $icon.anchor_right
