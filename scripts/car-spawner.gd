extends Node
class_name CarSpawner

# Spawns cars in front of the player. Always spawns in front,
# never in the back because we assume that the player is moving
# forward all the time, even though they can stop.

# Possible cars. Each one must be a Car type.
export(Array, PackedScene) var possibleCars
export(Array, PackedScene) var possiblePoliceCars

# Where to spawn the cars, only x position is taken.
export(Array, NodePath) var frontSpawnLocations
export(Array, NodePath) var backSpawnLocations

var possibleCarInstances = []
var totalProbability = 0

var possiblePoliceCarInstances = []
var totalPoliceProbability = 0

onready var player: Player = get_tree().get_nodes_in_group('player')[0]


func _ready():
    assert(possibleCars.size() > 0, "Missing possible cars for a spawner")
    assert(possiblePoliceCars.size() > 0, "Missing possible police cars for a spawner")
    assert(frontSpawnLocations.size() > 0, "No front spawn locations")
    assert(backSpawnLocations.size() > 0, "No back spawn locations")

    # preload all cars so we can work with their probabilities
    for b in possibleCars:
        var instance = b.instance() as Car
        possibleCarInstances.append(instance)
        totalProbability += instance.spawnProbability
    for b in possiblePoliceCars:
        var instance = b.instance() as Car
        possiblePoliceCarInstances.append(instance)
        totalPoliceProbability += instance.spawnProbability

    # preseed the cars going forward

    for _i in range(10):
        var car = chooseCar()
        car.speed = rand_range(4, 12)
        car.transform.origin.x = get_node(frontSpawnLocations[randi() % frontSpawnLocations.size()]).transform.origin.x
        car.transform.origin.z = player.transform.origin.z - 50 - rand_range(0, 100)
        add_child(car)

        car.connect('spinned', LevelProgress, '_onCarSpinned')
        car.connect('destroyed', LevelProgress, '_onCarDestroyed')


func _process(_delta):
    # TODO: this chance should increase in harder levels
    var probability = .08
    var policeProbability = .004

    if 'speed' in player and 'maxSpeed' in player and player.speed > 1:
        probability = lerp(0, .04, player.speed / player.maxSpeed)
        policeProbability = lerp(0, .002, player.speed / player.maxSpeed)

    if randf() < probability:
        spawnCar()
    if randf() < policeProbability:
        spawnPoliceCar()

func spawnCar():
    # limit max cars
    if get_tree().get_nodes_in_group('car').size() > 30:
        return

    # choose a new model randomly
    var car = chooseCar()
    car.speed = rand_range(4, 12)

    if randf() > .6:
        # higher chance to spawn forward facing car
        car.transform.origin.x = get_node(frontSpawnLocations[randi() % frontSpawnLocations.size()]).transform.origin.x

    else:
        # lower chance to spawn backward facing car
        car.transform.origin.x = get_node(backSpawnLocations[randi() % backSpawnLocations.size()]).transform.origin.x

        # flip the car
        car.rotate_y(PI)
        car.heading = -1

    if ('speed' in player and player.speed > 4) or car.heading < 0:
        car.transform.origin.z = player.transform.origin.z - 60 - rand_range(0, 60)
    else:
        car.transform.origin.z = player.transform.origin.z + 60

    add_child(car)
    car.connect('spinned', LevelProgress, '_onCarSpinned')
    car.connect('destroyed', LevelProgress, '_onCarDestroyed')

func spawnPoliceCar():
    # limit max police force
    if get_tree().get_nodes_in_group('police').size() > 10:
        return

    # choose a new model randomly
    var car = choosePoliceCar()

    if 'speed' in player:
        car.speed = player.speed
    else:
        car.speed = 6

    if randf() > .6:
        car.transform.origin.x = get_node(frontSpawnLocations[randi() % frontSpawnLocations.size()]).transform.origin.x
    else:
        car.transform.origin.x = get_node(backSpawnLocations[randi() % backSpawnLocations.size()]).transform.origin.x

    car.transform.origin.z = player.transform.origin.z + 25

    add_child(car)
    car.connect('spinned', LevelProgress, '_onCarSpinned')
    car.connect('destroyed', LevelProgress, '_onCarDestroyed')


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

func choosePoliceCar() -> Car:
    assert(totalPoliceProbability > 0, "Total police probability is 0 which makes this code crash!")

    var i = 0
    var counter = 0.0
    var target = randf() * totalPoliceProbability

    while counter < target and i <= possiblePoliceCarInstances.size():
        counter += possiblePoliceCarInstances[i].spawnProbability
        i += 1

    i -= 1

    return possiblePoliceCarInstances[i].duplicate()




