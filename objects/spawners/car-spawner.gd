extends Node
class_name CarSpawner

# Spawns cars in front of the player. If the player is moving, only spawns
# cars in the front. Otherwise cars going forward are spawned in the back
# to catch up. Also spawns police cars which are always going up.

# Possible cars. Each one must be a Car type.
@export var possibleCars: Array[PackedScene]
@export var possiblePoliceCars: Array[PackedScene]

var possibleCarInstances: Array[Car] = []
var possiblePoliceCarInstances: Array[Car] = []
var totalProbability := 0.0
var totalPoliceProbability := 0.0


func _ready():
    assert(possibleCars.size() > 0, 'Missing possible cars for a spawner')
    assert(possiblePoliceCars.size() > 0, 'Missing possible police cars for a spawner')

    # preload all cars so we can work with their probabilities
    for b in possibleCars:
        var instance = b.instantiate() as Car
        possibleCarInstances.append(instance)
        totalProbability += instance.spawnProbability

    for b in possiblePoliceCars:
        var instance = b.instantiate() as Car
        possiblePoliceCarInstances.append(instance)
        totalPoliceProbability += instance.spawnProbability


func _process(_delta):

    var player = get_tree().get_first_node_in_group('player') as Player
    if player == null:
        return

    if randf() < CarConstants.carSpawnChance:
        spawnCar(player)

    if randf() < CarConstants.policeSpawnChance:
        spawnPolice(player)


func spawnCar(player: Player):

    # limit max cars
    if get_tree().get_nodes_in_group('car').size() > HighwayConstants.maxTraffic:
        return

    # choose a new model randomly
    var car := chooseCar(possibleCarInstances, totalProbability)
    car.speed = car.maxSpeedFrom

    var goingUp: bool = randf() < CarConstants.carChanceGoingUp
    # TODO: I will need a better solution to determine when to start spawning cars behind the player
    var spawningUp: bool = not goingUp or ('speed' in player and player.speed > car.speed)

    positionAndInsertCar(car, player, spawningUp, goingUp)


func spawnPolice(player: Player):

    # limit max police cars
    if get_tree().get_nodes_in_group('police').size() > HighwayConstants.maxPolice:
        return

    # choose a new model randomly
    var car := chooseCar(possiblePoliceCarInstances, totalPoliceProbability)
    car.speed = player.speed

    # Always spawn the police facing up, and spawn it behind the
    # player to catch up. It does not look good if the police is spawned
    # in front and has to slowly wait for the player to catch up.
    positionAndInsertCar(car, player, false, true)



func positionAndInsertCar(car: Node3D, player: Node3D, spawningUp: bool, goingUp: bool):

    # rotate the car corrently
    if not goingUp:
        car.heading = -1
        car.rotate_y(PI)

    # position it on the Z axis
    if spawningUp:
        car.position.z = player.global_position.z - HighwayConstants.blockLength * 1.6
    else:
        car.position.z = player.global_position.z + HighwayConstants.blockLength * 0.8

    # find the block for this Z position
    var block: Block
    for checkedBlock in get_tree().get_nodes_in_group('block'):
        block = checkedBlock
        if car.position.z >= block.global_position.z - HighwayConstants.blockLength / 2.0:
            break

    # find the possible lanes for this position
    var lanesUp: Array[NodePath]
    var lanesDown: Array[NodePath]

    if goingUp:
        lanesUp = block.positiveLanesUp
        lanesDown = block.positiveLanesDown
    else:
        lanesUp = block.negativeLanesUp
        lanesDown = block.negativeLanesDown

    # for every lane, calculate the correct X position
    var lanePositions: Array[float]

    for i in range(maxi(lanesUp.size(), lanesDown.size())):
        var laneDown := block.get_node(lanesDown[mini(i, lanesDown.size() - 1)])
        var laneUp := block.get_node(lanesUp[mini(i, lanesUp.size() - 1)])

        # position for lane `i`
        var ix = lerpf(
            laneDown.global_position.x,
            laneUp.global_position.x,
            clampf((car.position.z - laneDown.global_position.z) / (laneUp.global_position.z - laneDown.global_position.z), 0.0, 1.0)
        )

        lanePositions.append(ix)

    # Now choose a lane to spawn in. For these, we are going to randomly try
    # each line until one of them is free to spawn a car (checking nearby cars for proximity).

    var lanesToTry = range(lanePositions.size())
    lanesToTry.shuffle()

    for lane in lanesToTry:

        var bounds := car.get_node('collision') as CollisionShape3D

        # car can specify separate spawn bounds
        if car.has_node('spawn-bounds'):
            bounds = car.get_node('spawn-bounds') as CollisionShape3D

        var aabb := AABB(car.position + bounds.position, bounds.shape.size)
        aabb.position.x = lanePositions[lane]

        # check whether any car is in the way
        var positionFree := true
        for other in get_tree().get_nodes_in_group('car'):

            # skip if we already know that the position is not free
            if not positionFree: continue

            var otherBounds := other.get_node('collision') as CollisionShape3D

            # car can specify separate spawn bounds
            if other.has_node('spawn-bounds'):
                otherBounds = other.get_node('spawn-bounds') as CollisionShape3D

            var otherAABB := AABB(otherBounds.global_position, otherBounds.shape.size)
            if otherAABB.intersects(aabb):
                # oops, would collide with this car
                positionFree = false


        # if this position is not free, continue checking the next lane
        if not positionFree: continue


        # success! spawn the car here
        car.position.x = lanePositions[lane]

        # set the lane for traffic cars
        if 'currentLane' in car:
            car.currentLane = lane
            car.previousLane = car.currentLane

        add_child(car)

        break




func chooseCar(instances: Array[Car], totalProbability: float) -> Car:
    assert(totalProbability > 0, 'Total probability is 0 which makes this code crash!')

    var i := 0
    var counter := 0.0
    var target := randf() * totalProbability

    while counter < target and i <= instances.size():
        counter += instances[i].spawnProbability
        i += 1

    i -= 1

    return instances[i].duplicate()
