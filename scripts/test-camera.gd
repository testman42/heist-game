extends Camera

var speed = 5
var mouse_sens = .4
var camera_anglev = 80

func _enter_tree():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _leave_tree():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
    var input = Input.get_vector('move_left', 'move_right', 'accelerate', 'break')
    var mouse = Input.get_mouse_mode()

    translate(speed * delta * Vector3(input.x, 0, input.y))

func _input(event):
    if event is InputEventMouseMotion:
        rotate_y(deg2rad(-event.relative.x*mouse_sens))
        var changev=-event.relative.y*mouse_sens
        rotate_object_local(Vector3.RIGHT, deg2rad(changev))

