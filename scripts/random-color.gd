extends Spatial

# Randomizes the hue of the color of the material.

export(Array, NodePath) var nodesToEdit

func _ready():
    assert(nodesToEdit.size() > 0, 'Missing nodes to edit')

    # duplicate the first node's material
    var first = get_node(nodesToEdit[0])
    var mat = first.material as SpatialMaterial
    assert(mat != null, 'First node does not have a material')

    var newMat = mat.duplicate() as SpatialMaterial
    newMat.albedo_color = Color.from_hsv(randf(), mat.albedo_color.s, mat.albedo_color.v)

    for i in nodesToEdit:
        var node = get_node(i)
        node.material = newMat

