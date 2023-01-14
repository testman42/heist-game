extends Node3D

# Camera that smoothly follows the player and zooms
# based on their speed.


var player: Player


func _process(delta):
    var target := getTarget()

    target.y = move_toward(transform.origin.y, target.y, delta * 2.4 * min(3, abs(target.y - transform.origin.y)))
    transform.origin = target
    $camera.look_at(target, Vector3.UP)


func getTarget() -> Vector3:
    var target: Vector3

    # used cached player if possible
    if player != null and is_instance_valid(player) and player.is_in_group('player'):
        pass

    else:
        # find new player, if any
        var nodes := get_tree().get_nodes_in_group('player')
        if nodes.size() == 0:
            player = null
            return transform.origin

        player = nodes[0]

    target = player.transform.origin
    target.x /= 2

    if 'speed' in player and 'maxSpeed' in player:
        target.y = player.speed / player.maxSpeed * 13

    return target
