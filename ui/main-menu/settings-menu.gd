extends Control

signal switchScene(name)


func _on_done_pressed():
    emit_signal('switchScene', 'main')
