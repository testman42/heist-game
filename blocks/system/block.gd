extends Node3D
class_name Block

# Represents a block, a part of the level that is dynamically spawned as
# the player moves forward. Contains the models and information about
# the highway, such as the traffic lanes.

# lanes going in the same way as the player (heading=1)
# up is on the Z- side of the block, down is Z+ side
@export var positiveLanesUp: Array[NodePath]
@export var positiveLanesDown: Array[NodePath]

# lanes going in the opposite way as the player (heading=-1)
# up is on the Z- side of the block, down is Z+ side
@export var negativeLanesUp: Array[NodePath]
@export var negativeLanesDown: Array[NodePath]
