extends Node3D

# the total length of the line to generate
@export var length := 100

# the object to spawn as a single line mark
# assume that the lineObject has length of 1
@export var lineObject: PackedScene


func _ready():
    for i in range(length / 2):
        var z = -length / 2 + i * 2 + 1
        var obj = lineObject.instantiate() as Node3D
        obj.translate(Vector3(0, 0, z))

        add_child(obj)

