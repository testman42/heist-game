extends Spatial

onready var player := get_tree().get_nodes_in_group('player')[0] as Player

func _ready():
    # $tween.follow_method(self, 'getTarget', transform.origin, self, 'setPos', 10)
    pass

func _process(delta):
    var target := getTarget()

    target.y = move_toward(transform.origin.y, target.y, delta * 2.4 * min(3, abs(target.y - transform.origin.y)))
    setPos(target)
    $camera.look_at(target, Vector3.UP)

func getTarget() -> Vector3:
    var target := player.get_transform().origin
    target.x /= 2

    if 'speed' in player and 'maxSpeed' in player:
        target.y = player.speed / player.maxSpeed * 13

    return target

func setPos(pos: Vector3):
    transform.origin = pos

