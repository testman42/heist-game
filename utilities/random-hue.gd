extends Node

# Randomizes the hue of the color of the material.
# All provided nodes will share the same material.

@export var nodesToEdit: Array[NodePath]

func _ready():
    assert(nodesToEdit.size() > 0, 'Missing nodes to edit color')

    # duplicate the first node's material
    var first := get_node(nodesToEdit[0])
    var mat := first.material as StandardMaterial3D
    assert(mat != null, 'First node does not have a material')

    var newMat := mat.duplicate()
    newMat.albedo_color = Color.from_hsv(randf(), mat.albedo_color.s, mat.albedo_color.v)

    for i in nodesToEdit:
        var node := get_node(i)
        node.material = newMat

