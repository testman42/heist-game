extends Control

signal switchScene(name)


func _on_quickplay_pressed():
    emit_signal('switchScene', 'quickplay')


func _on_settings_pressed():
    emit_signal('switchScene', 'settings')


func _on_exit_pressed():
    get_tree().quit()
