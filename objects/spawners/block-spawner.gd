extends Node
class_name BlockSpawner

# Spawns level blocks as the player is moving forward.
# **All blocks must be 50 meters long.**
# The spawner always assumes that the child nodes - blocks are ordered from back to front. It always
# checks just the first block for deleting and appends new blocks at the end.
# Uses a state machine and a spawn chart for choosing blocks so complex
# chain of blocks can be generated.

# spawn chart to use
@export var spawnChart: PackedScene

# chart instance
var chart: Node
# last spawned block, if any
var current: Node


func _ready():

    # prepare the spawn chart
    chart = spawnChart.instantiate()
    assert(chart.get_child_count() > 0, 'Spawn chart cannot be empty')



func _process(_delta):
    deleteOldBlocks()
    spawnNewBlocks()



func deleteOldBlocks():
    # all blocks that are already a few meters behind the player can be deleted

    if get_child_count() == 0:
        return


    var player = get_tree().get_first_node_in_group('player')
    if player == null:
        # no player in the level, leave blocks be
        return

    var block := get_child(0) as Node3D

    if (block.transform.origin.z - player.global_transform.origin.z) > HighwayConstants.blockLength * 2:
        block.queue_free()


func spawnNewBlocks():

    # 8 blocks are always kept in the scene
    if get_child_count() >= 4:
        return

    # choose a new block randomly
    var block := chooseBlock()

    # spawn the block after the last one, which is 50 meters in front of it
    var offset = 0

    if get_child_count() > 0:
        offset = get_child(-1).transform.origin.z - HighwayConstants.blockLength

    block.transform.origin.z = offset
    add_child(block)


func chooseBlock() -> Block:

    var result: Block


    # initialize the current pointer
    if current == null:
        current = chart.get_child(0)


    # check the current node in the chart and ACT based on its type

    while true:

        print('block spawn current is ', current.name)

        if current is SpawnBlock:
            assert(current.block, 'Missing block in SpawnBlock')
            result = current.block.instantiate()
            break

        elif current is SpawnGroup:
            assert(current.get_child_count() > 0, 'Spawn group has no children')
            current = chooseChildNode(current)

        else:
            assert(false, 'Unknown node type')
            break


    # MOVE to the next node according to the connections

    # if node is in a group, it can omit its connections and just delegate
    # to the group
    while current.connections == null or current.connections.size() <= 0:

        assert(current.get_parent() != chart, 'Top-level node missing connections')
        current = current.get_parent()


    # choose a connection by their weight, then move there
    var connection := chooseConnection(current.connections)

    current = current.get_node(connection.node)
    assert(current != null, 'Connection is missing the node')

    # finally, return the new block

    assert(result, 'Failed to generate a block')
    print('chose block ', result.name)
    return result


func chooseConnection(connections: Array[Connection]) -> Connection:

    # optimization because this will happen in the chart sometimes
    if connections.size() == 1:
        return connections[0]

    var total := 0.0
    for c in connections:
        total += c.probability

    var i = 0
    var counter = 0.0
    var target = randf() * total

    while counter < target and i <= connections.size():
        counter += connections[i].probability
        i += 1

    i -= 1

    return connections[i]


func chooseChildNode(node: Node) -> Node:

    var children := node.get_children()

    var total := 0.0
    for c in children:
        total += c.probability

    var i = 0
    var counter = 0.0
    var target = randf() * total

    while counter < target and i <= children.size():
        counter += children[i].probability
        i += 1

    i -= 1

    return children[i]
