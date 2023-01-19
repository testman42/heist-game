extends RigidBody3D
class_name DynamicObject

# This script makes sure that dynamic objects that can be knocked away
# from their initial position in a block do not get deleted when
# the block gets deleted, rather when they get too far behind the player.

@export var autoReparentToRoot := true

func _ready():

    # Move the node to the root. Needs to be deferred because
    # the parent is still "busy setting up children".
    if autoReparentToRoot:
        call_deferred('reparent', get_tree().root)


func _process(_delta):
    # delete if too far from the player
    var players := get_tree().get_nodes_in_group('player')
    if players.size() <= 0: return

    if global_position.z > players[0].global_position.z + HighwayConstants.blockLength * 2:
        queue_free()

