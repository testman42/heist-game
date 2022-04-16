extends Spatial

var scrollSpeed = 2


func _process(delta):
    translate(Vector3.FORWARD * delta * scrollSpeed)
