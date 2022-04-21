extends Popup

var shown = false

func _process(_delta):
    if !LevelProgress.playerDead or shown:
        return

    shown = true

    # wait for a few seconds before showing
    yield(get_tree().create_timer(2), 'timeout')

    popup()
