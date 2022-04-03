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

func _onSceneChange():
    setup()

func _onPlayerMoved(delta):
    distance += delta

func _onPlayerCollided(amount):
    money -= amount * 8


