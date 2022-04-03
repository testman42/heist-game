extends Node

# Contains the global information about the current level.

export var money = 1000
export var distance = 0
export var targetDistance = 100

onready var player := get_tree().get_nodes_in_group('player')[0] as Player

func _ready():
    player.connect('player_moved', self, '_onPlayerMoved')


func _onPlayerMoved(delta):
    distance += delta


