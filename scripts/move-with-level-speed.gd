extends Spatial
class_name MoveWithLevelSpeed

# Adding this script to a node makes it move with the speed of the level.
# Used for cars, the road, everything!

func _process(delta):
    var distanceToMove = delta * LevelSpeed.speed
    translate(Vector3(0, 0, distanceToMove))

