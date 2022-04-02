extends Spatial

# the total length of the line to generate
export var length = 100

# the object to spawn as a single line mark
# assume that the lineObject has length of 1
export(PackedScene) var lineObject


func _ready():
    for i in range(length / 2):
        var z = -length / 2 + i * 2 + 1
        var obj = lineObject.instance() as Spatial
        obj.translate(Vector3(0, 0, z))

        add_child(obj)

