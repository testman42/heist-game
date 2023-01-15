extends Node
class_name CarSpawner

# Spawns cars in front of the player. If the player is moving, only spawns
# cars in the front. Otherwise cars going forward are spawned in the back
# to catch up.

# Possible cars. Each one must be a Car type.
@export var possibleCars: Array[PackedScene]

var possibleCarInstances = []
var totalProbability = 0


func _ready():
    assert(possibleCars.size() > 0, 'Missing possible cars for a spawner')

    # preload all cars so we can work with their probabilities
    for b in possibleCars:
        var instance = b.instantiate() as Car
        possibleCarInstances.append(instance)
        totalProbability += instance.spawnProbability


func _process(_delta):
    # TODO: this chance should increase in harder levels
    var probability := CarConstants.carSpawnChance

    var players = get_tree().get_nodes_in_group('player')
    if players.size() <= 0:
        return

    var player := players[0] as Player

    if 'speed' in player and 'maxSpeed' in player and player.speed > 1:
        probability = lerpf(0, probability, player.speed / player.maxSpeed)

    if randf() < probability:
        spawnCar(player)


func spawnCar(player: Player):
    # limit max cars
    if get_tree().get_nodes_in_group('car').size() > HighwayConstants.maxTraffic:
        return

    # choose a new model randomly
    var car = chooseCar()
    car.speed = car.maxSpeedFrom

    if randf() < CarConstants.carChanceGoingUp:
        car.transform.origin.x = HighwayConstants.lanes[randi() % HighwayConstants.lanes.size()]
    else:
        car.transform.origin.x = -HighwayConstants.lanes[randi() % HighwayConstants.lanes.size()]
        car.heading = -1

    if car.heading < 0 or ('speed' in player and player.speed > 4):
        car.transform.origin.z = player.transform.origin.z - HighwayConstants.blockLength * 1.5
    else:
        car.transform.origin.z = player.transform.origin.z + HighwayConstants.blockLength * 1.5

    add_child(car)

    # check whether the car collides with anything, if true, just move it back
    while car.move_and_collide(Vector3(0, 0, -.1), true, true, true):
        car.transform.origin.z += sign(car.transform.origin.z)


func chooseCar() -> Car:
    assert(totalProbability > 0, 'Total probability is 0 which makes this code crash!')

    var i = 0
    var counter = 0.0
    var target = randf() * totalProbability

    while counter < target and i <= possibleCarInstances.size():
        counter += possibleCarInstances[i].spawnProbability
        i += 1

    i -= 1

    return possibleCarInstances[i].duplicate()
