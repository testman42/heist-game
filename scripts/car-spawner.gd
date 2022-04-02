extends Node
class_name CarSpawner

# Spawns cars in front of the player. Always spawns in front,
# never in the back because we assume that the player is moving
# forward all the time, even though they can stop.

# Possible cars. Each one must be a Car type.
export(Array, PackedScene) var possibleCars

# Where to spawn the cars, only x position is taken.
export(Array, NodePath) var frontSpawnLocations
export(Array, NodePath) var backSpawnLocations

var possibleCarInstances = []
var totalProbability = 0

onready var player: Player = get_tree().get_nodes_in_group('player')[0]


func _ready():
    assert(possibleCars.size() > 0, "Missing possible cars for a spawner")
    assert(frontSpawnLocations.size() > 0, "No front spawn locations")
    assert(backSpawnLocations.size() > 0, "No back spawn locations")

    # preload all cars so we can work with their probabilities
    for b in possibleCars:
        var instance = b.instance() as Car
        possibleCarInstances.append(instance)
        totalProbability += instance.spawnProbability


func _process(_delta):
    spawnNewCars()

func spawnNewCars():

    # TODO: this change should increase in harder levels
    var probability = lerp(0, .06, player.speed / player.maxSpeed)

    if randf() > probability:
        return

    # choose a new model randomly
    var car = chooseCar()
    car.speed = -rand_range(4, 12)

    if randf() > .3:
        # higher chance to spawn forward facing car
        car.transform.origin.x = get_node(frontSpawnLocations[randi() % frontSpawnLocations.size()]).transform.origin.x

    else:
        # lower chance to spawn backward facing car
        car.transform.origin.x = get_node(backSpawnLocations[randi() % backSpawnLocations.size()]).transform.origin.x

        # flip the car
        car.rotate_y(PI)
        car.heading = -1

    car.transform.origin.z = player.transform.origin.z - 100

    add_child(car)


func chooseCar() -> Car:
    assert(totalProbability > 0, "Total probability is 0 which makes this code crash!")

    var i = 0
    var counter = 0.0
    var target = randf() * totalProbability

    while counter < target and i <= possibleCarInstances.size():
        counter += possibleCarInstances[i].spawnProbability
        i += 1

    i -= 1

    return possibleCarInstances[i].duplicate()


