extends CollisionShape
class_name SpawnInArea

# Spawns a number of provided objects in an area.
# Must contain a BoxShape shape.

export var spawnMin = 0
export var spawnMax = 10
export(PackedScene) var instanceToSpawn

func _ready():
    if not GameController.trees:
        return

    var box := shape as BoxShape
    assert(box, 'Spawner only works with boxes')
    var bounds := box.extents

    for _i in range(spawnMin + randi() % (spawnMax - spawnMin)):
        var instance = instanceToSpawn.instance()
        add_child(instance)

        instance.transform.origin.x = rand_range(-bounds.x, bounds.x)
        instance.transform.origin.z = rand_range(-bounds.z, bounds.z)

