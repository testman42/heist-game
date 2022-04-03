extends RigidBody
class_name DynamicObject

# This make sure that dynamic objects that can be knocked away
# from their initial position in a block do not get deleted when
# the block gets deleted, rather when they get too far behind the player.

var player: Player

func _ready():
    if get_tree().get_nodes_in_group('player').size() > 0:
        player = get_tree().get_nodes_in_group('player')[0]

    var global = get_global_transform()

    get_parent().call_deferred('remove_child', self)
    get_node('/root').call_deferred('add_child', self)

    transform = global

func _process(_delta):
    if player and transform.origin.z > player.transform.origin.z + 60:
        queue_free()

