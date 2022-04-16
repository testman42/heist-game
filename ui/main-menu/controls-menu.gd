extends Control

signal switchScene(name)


func _ready():
    $done.grab_focus()


func _on_done_pressed():
    emit_signal('switchScene', 'main')
