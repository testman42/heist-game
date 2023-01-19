extends Prop
class_name Trailer

# Controls the trailer of a truck. Sets it up as a separate
# rigid body. On collision, it gets detached from the truck.

@export var truck: NodePath
@export var truckPin: NodePath

var joint: Joint3D
var truckNode: Node3D
var truckPinNode: Node3D


func _ready() -> void:
    super()

    var setup := func() -> void:

        truckNode = get_node(truck)
        truckPinNode = get_node(truckPin)

        # move to the root NOW before creating the joint
        reparent(get_tree().root)
        truckNode.reparent(get_tree().root)

        # add a new pin which holds this trailer to the truck
        joint = PinJoint3D.new()
        joint.name = 'joint'
        joint.set_exclude_nodes_from_collision(false)

        # position it to the truck's pin point
        joint.position = to_local(truckPinNode.global_position)

        # connect the bodies
        joint.set_node_a(truckNode.get_path())
        joint.set_node_b(get_path())

        # add the joint to the trailer
        add_child(joint)

    # deferred setup because of DynamicObject
    setup.call_deferred()


func _process(delta: float) -> void:
    super(delta)
    checkDetach()


func checkDetach() -> void:

    if joint == null: return
    if not is_instance_valid(truckNode): return

    # Check the X and Z rotation of the trailer. If it leans too much, detach.
    if absf(rotation.x) > PI/16 or absf(rotation.z) > PI/16:
        detach()


func detach() -> void:

    if joint == null: return

    joint.queue_free()
    joint = null


