extends Node
class_name BlockSpawner

# Spawns level blocks as the player is moving forward.
# All blocks *must* be 100x100 meters.

# Possible blocks. Each one must be a Block type.
export(Array, PackedScene) var possibleBlocks

var possibleBlocksInstances = []
var totalProbability = 0


func _ready():
    assert(possibleBlocks.size() > 0, "Missing possible blocks for a spawner")

    # preload all blocks so we can work with their probabilities
    for b in possibleBlocks:
        var instance = b.instance() as Block
        possibleBlocksInstances.append(instance)
        totalProbability += instance.spawnProbability


func _process(_delta):
    deleteOldBlocks()
    spawnNewBlocks()



func deleteOldBlocks():
    # all blocks that are already 100 meters or more behind the player can be deleted,
    # assuming that the player is always at 0
    for child in get_children():
        var block = child as Block

        assert(block != null, "Unexpected child node which is not a Block")

        if block.get_global_transform().origin.z > 100:
            block.queue_free()

func spawnNewBlocks():

    if get_child_count() >= 3:
        return

    # choose a new block randomly
    var block = chooseBlock()

    # TODO: spawn required blocks before and after

    # spawn the block after the last one, which is 100 meters in front of it
    var offset = get_child(get_child_count() - 1).get_global_transform().origin.z - 99.5

    block.translate(Vector3(0, 0, offset))
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

