extends Node
class_name CarSpawner

# Spawns cars in front of the player. Always spawns in front,
# never in the back because we assume that the player is moving
# forward all the time, even though they can stop.

# Possible cars. Each one must be a Car type.
export(Array, PackedScene) var possibleCars
export(Array, PackedScene) var possiblePoliceCars

export var disableCars = false
export var disablePolice = false

var possibleCarInstances = []
var totalProbability = 0

var possiblePoliceCarInstances = []
var totalPoliceProbability = 0

var player


func _ready():
    assert(possibleCars.size() > 0, "Missing possible cars for a spawner")
    assert(possiblePoliceCars.size() > 0, "Missing possible police cars for a spawner")

    # preload all cars so we can work with their probabilities
    for b in possibleCars:
        var instance = b.instance() as Car
        possibleCarInstances.append(instance)
        totalProbability += instance.spawnProbability
    for b in possiblePoliceCars:
        var instance = b.instance() as Car
        possiblePoliceCarInstances.append(instance)
        totalPoliceProbability += instance.spawnProbability


func _process(_delta):
    # TODO: this chance should increase in harder levels
    var probability = .04
    var policeProbability = .003

    var nodes = get_tree().get_nodes_in_group('player')
    if nodes.size() > 0:
        player = nodes[0]
    else:
        player = null

    if 'speed' in player and 'maxSpeed' in player and player.speed > 1:
        probability = lerp(0, probability, player.speed / player.maxSpeed)
        policeProbability = lerp(0, policeProbability, player.speed / player.maxSpeed)

    if GameController.traffic and !disableCars and randf() < probability:
        spawnCar()
    if GameController.police and !disablePolice and randf() < policeProbability:
        spawnPoliceCar()

func spawnCar():
    # limit max cars
    if get_tree().get_nodes_in_group('car').size() > HighwayConstants.maxTraffic:
        return

    # choose a new model randomly
    var car = chooseCar()
    car.speed = car.maxSpeedFrom

    if randf() < .4:
        car.transform.origin.x = HighwayConstants.lanes[randi() % HighwayConstants.lanes.size()]
    else:
        car.transform.origin.x = -HighwayConstants.lanes[randi() % HighwayConstants.lanes.size()]
        car.heading = -1

    if ('speed' in player and player.speed > 4) or car.heading < 0:
        car.transform.origin.z = player.transform.origin.z - HighwayConstants.blockLength * 1.5
    else:
        car.transform.origin.z = player.transform.origin.z + HighwayConstants.blockLength * 1.5

    add_child(car)
    car.connect('spinned', LevelProgress, '_onCarSpinned', [car])
    car.connect('destroyed', LevelProgress, '_onCarDestroyed', [car])

    # check whether the car collides with anything, if true, just move it back
    while car.move_and_collide(Vector3(0, 0, -.1), true, true, true):
        car.transform.origin.z -= 1

func spawnPoliceCar():
    # limit max police force
    if get_tree().get_nodes_in_group('police').size() > HighwayConstants.maxPolice:
        return

    # choose a new model randomly
    var car = choosePoliceCar()

    if 'speed' in player:
        car.speed = player.speed
    else:
        car.speed = 6

    car.transform.origin.x = rand_range(-HighwayConstants.grass, HighwayConstants.grass)

    if randf() < .4:
        car.transform.origin.z = player.transform.origin.z - HighwayConstants.blockLength * 1.5
    else:
        car.transform.origin.z = player.transform.origin.z + HighwayConstants.blockLength * 1.5

    add_child(car)
    car.connect('spinned', LevelProgress, '_onCarSpinned', [car])
    car.connect('destroyed', LevelProgress, '_onCarDestroyed', [car])

    # check whether the car collides with anything, if true, just move it back
    while car.move_and_collide(Vector3(0, 0, .1), true, true, true):
        car.transform.origin.z += 1


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
