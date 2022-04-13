extends Control

# Manages the main menu transitions.

export(NodePath) var sceneRoot

export(PackedScene) var mainScene
export(PackedScene) var settingsScene


func _ready():
    assert(sceneRoot, 'Missing scene root')

    switchTo(mainScene)


func switchTo(scene: PackedScene):
    var root = get_node(sceneRoot)

    # remove old scene
    for c in root.get_children():
        root.remove_child(c)
        c.queue_free()

    # add new scene
    var instance = scene.instance()
    root.add_child(instance)

    if instance.has_signal('switchScene'):
        instance.connect('switchScene', self, '_on_switchScene')


func _on_switchScene(name: String):
    match(name):
        'main': switchTo(mainScene)
        'settings': switchTo(settingsScene)

        _: printerr('Unrecognized main menu scene name: ', name)
