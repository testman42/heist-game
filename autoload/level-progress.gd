extends Node

# Contains the global information about the current level.

export var money = 1000
export var distance = 0
export var targetDistance = 100

var player: Player

func setup():
    if get_tree().get_nodes_in_group('player').size() <= 0:
        return

    player = get_tree().get_nodes_in_group('player')[0]
    player.connect('player_moved', self, '_onPlayerMoved')
    player.connect('player_collision', self, '_onPlayerCollided')

    # TODO
    money = rand_range(4000, 10000)
    distance = 0
    targetDistance = rand_range(200, 800)


func _process(_delta):
    if distance >= targetDistance:
        # level complete
        # TODO
        GameController.levelComplete()


func _onSceneChange():
    setup()

func _onPlayerMoved(delta):
    distance += delta

func _onPlayerCollided(amount):
    # TODO: this should decrease with armor and increase with difficulty
    money -= amount * 2

func _onCarSpinned():
    money += rand_range(10, 60)

func _onCarDestroyed():
    money += rand_range(20, 100)


