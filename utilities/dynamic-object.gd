extends RigidBody3D
class_name DynamicObject

# This script makes sure that dynamic objects that can be knocked away
# from their initial position in a block do not get deleted when
# the block gets deleted, rather when they get too far behind the player.

func _ready():
    var targetTransform = global_transform

    # move the node to the root
    get_parent().call_deferred('remove_child', self)
    get_node('/root').call_deferred('add_child', self)

    # reposition
    call_deferred('set_transform', targetTransform)


func _process(_delta):
    # delete if too far from the player
    var players := get_tree().get_nodes_in_group('player')
    if players.size() <= 0: return

    if global_position.z > players[0].global_position.z + HighwayConstants.blockLength * 2:
        queue_free()

