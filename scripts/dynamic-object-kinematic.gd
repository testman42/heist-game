extends KinematicBody
class_name DynamicObjectKinematic

# This make sure that dynamic objects that can be knocked away
# from their initial position in a block do not get deleted when
# the block gets deleted, rather when they get too far behind the player.

var player: Spatial

func _ready():
    if get_tree().get_nodes_in_group('player').size() > 0:
        player = get_tree().get_nodes_in_group('player')[0]

    var global = get_global_transform()

    get_parent().call_deferred('remove_child', self)
    var root = get_node('/root')
    root.get_child(root.get_child_count() - 1).call_deferred('add_child', self)

    transform = global

func _process(_delta):
    if player and is_instance_valid(player) and transform.origin.distance_squared_to(player.transform.origin) > 10000:
        queue_free()

