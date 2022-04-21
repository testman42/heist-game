extends Node

# Contains the global information about the current level.

export var money = 1000
export var distance = 0
export var targetDistance = 100

var player
export var playerDead = false

func _ready():
    setup()

func setup():
    if get_tree().get_nodes_in_group('player').size() <= 0:
        return

    playerDead = false
    distance = 0

    player = get_tree().get_nodes_in_group('player')[0]

    if player.has_signal('player_moved'):
        player.connect('player_moved', self, '_onPlayerMoved')
    if player.has_signal('player_collision'):
        player.connect('player_collision', self, '_onPlayerCollided')

    money = rand_range(8, 80)
    distance = 0
    targetDistance = 1000* money * rand_range(.4, .9)


func _process(_delta):
    if distance >= targetDistance:
        # level complete
        SceneSwitcher.switchToScene('outro')
        setup()

    if player and is_instance_valid(player) and money <= 0:
        if player.has_method('destroyCar'):
            player.destroyCar()
            playerDead = true


func _onSceneChange():
    setup()

func _onPlayerMoved(delta):
    distance += delta

func _onPlayerCollided(amount):
    # TODO: this should decrease with armor and increase with difficulty
    money -= amount * 9.2

func _onCarSpinned(car):
    if car.is_in_group('police'):
        money += rand_range(20, 60)

func _onCarDestroyed(car):
    if car.is_in_group('police'):
        money += rand_range(50, 120)
