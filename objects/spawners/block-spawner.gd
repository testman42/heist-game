extends Node
class_name BlockSpawner

# Spawns level blocks as the player is moving forward.
# **All blocks must be 50 meters long.**

# Possible blocks. Each one must be a Block type.
export(Array, PackedScene) var possibleBlocks

var possibleBlocksInstances = []
var totalProbability = 0

onready var player: Player = get_tree().get_nodes_in_group('player')[0]


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
    # all blocks that are already a few meters behind the player can be deleted

    for child in get_children():
        var block = child as Block

        assert(block != null, "Unexpected child node which is not a Block")

        if (block.get_global_transform().origin.z - player.get_global_transform().origin.z) > 60:
            block.queue_free()

func spawnNewBlocks():

    if get_child_count() >= 5:
        return

    # choose a new block randomly
    var block = chooseBlock()

    # TODO: spawn required blocks bfore and after

    # spawn the block after the last one, which is 50 meters in front of it
    var speed = 1
    if 'speed' in player:
        speed = player.speed


    var offset = 0

    if get_child_count() > 0:
        offset = get_child(get_child_count() - 1).get_global_transform().origin.z - 50 + speed

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

