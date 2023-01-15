extends Node3D

# Sets up a cross line for the road by duplicating
# its one child (single line mark) to fill the length of a block.


func _ready() -> void:
    # start with the line child node
    var line := $line
    var lineLength: float = $line.extents.z * 2.0

    # prepare the pos and the first line
    var pos := -HighwayConstants.blockLength / 2.0
    line.position.z = pos + lineLength / 2.0

    # increase pos by line + blank space
    pos += lineLength * 2

    # generate the rest
    while pos < HighwayConstants.blockLength / 2.0:

        # make a new line
        line = line.duplicate()
        add_child(line)

        # position line
        line.position.z = pos + lineLength / 2.0

        # increase pos by line + blank space
        pos += lineLength * 2
