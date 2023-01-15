extends Node
class_name BlockSpawner

# Spawns level blocks as the player is moving forward.
# **All blocks must be 50 meters long.**
# The spawner always assumes that the child nodes - blocks are ordered from back to front. It always
# checks just the first block for deleting and appends new blocks at the end.
# All blocks are instantiated and kept in memory for using their probabilities,
# so they cannot have any logic.

# Possible blocks. Each one must be a Block type.
@export var possibleBlocks: Array[PackedScene]

var possibleBlocksInstances: Array[Block] = []
var totalProbability := 0.0


func _ready():
    assert(possibleBlocks.size() > 0, 'Missing possible blocks for a spawner')

    # preload all blocks so we can work with their probabilities
    for b in possibleBlocks:
        var instance = b.instantiate() as Block
        possibleBlocksInstances.append(instance)
        totalProbability += instance.spawnProbability


func _process(_delta):
    deleteOldBlocks()
    spawnNewBlocks()



func deleteOldBlocks():
    # all blocks that are already a few meters behind the player can be deleted

    if get_child_count() == 0:
        return


    var players = get_tree().get_nodes_in_group('player')
    if players.size() <= 0:
        # no player in the level, leave blocks be
        return

    var block := get_child(0) as Block
    assert(block != null, "Unexpected child node which is not a Block")

    if (block.transform.origin.z - players[0].global_transform.origin.z) > HighwayConstants.blockLength * 2:
        block.queue_free()


func spawnNewBlocks():

    if get_child_count() >= 6:
        return

    # choose a new block randomly
    var block := chooseBlock()

    # TODO: spawn required blocks before and after

    # spawn the block after the last one, which is 50 meters in front of it
    var offset = 0

    if get_child_count() > 0:
        offset = get_child(-1).transform.origin.z - HighwayConstants.blockLength

    block.transform.origin.z = offset
    add_child(block)


func chooseBlock() -> Block:
    assert(totalProbability > 0, "Total probability is 0 which makes this code crash!")

    var i = 0
    var counter = 0.0
    var target = randf() * totalProbability

    while counter < target and i <= possibleBlocksInstances.size():
        counter += possibleBlocksInstances[i].spawnProbability
        i += 1

    i -= 1

    return possibleBlocksInstances[i].duplicate()

