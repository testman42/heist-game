extends CollisionShape3D
class_name SpawnInArea

# Spawns a number of provided objects in an area.
# Must contain a BoxShape shape.

@export var spawnMin = 0
@export var spawnMax = 10
@export var instanceToSpawn: PackedScene

func _ready():
    var box := shape as BoxShape3D
    assert(box, 'Spawner only works with boxes')
    var bounds := box.size / 2

    for _i in range(spawnMin + randi() % (spawnMax - spawnMin)):
        var instance := instanceToSpawn.instantiate()
        add_child(instance)

        instance.transform.origin.x = randf_range(-bounds.x, bounds.x)
        instance.transform.origin.z = randf_range(-bounds.z, bounds.z)

