extends Node3D
class_name Block

# Represents a block, a part of the level that is dynamically spawned as
# the player moves forward. Contains the models and information about
# the highway, such as the traffic lanes.

# lanes going up (heading=1)
@export var positiveLanes: Array[NodePath]
# lanes going down (heading=-1)
@export var negativeLanes: Array[NodePath]
