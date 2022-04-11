extends Spatial


func _process(delta):
    var target := getTarget()

    target.y = move_toward(transform.origin.y, target.y, delta * 2.4 * min(3, abs(target.y - transform.origin.y)))
    transform.origin = target
    $camera.look_at(target, Vector3.UP)


func getTarget() -> Vector3:
    var nodes := get_tree().get_nodes_in_group('player')
    if nodes.size() == 0:
        return transform.origin

    var player = nodes[0]
    var target = player.transform.origin

    target.x /= 2

    if 'speed' in player and 'maxSpeed' in player:
        target.y = player.speed / player.maxSpeed * 13

    return target
