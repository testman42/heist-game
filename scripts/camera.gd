extends Spatial

onready var player := get_tree().get_nodes_in_group('player')[0] as Player

func _process(delta):
    var target := player.get_transform().origin

    var dolly := Vector3(0, get_transform().origin.y, target.z)
    var targetHeight = player.speed / player.maxSpeed * 10

    var newHeight = move_toward(dolly.y, targetHeight, 2 * delta)
    dolly.y = newHeight

    transform.origin = dolly
    $camera.look_at(Vector3(0, 0, target.z), Vector3.UP)

