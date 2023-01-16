extends DynamicObject
class_name Prop

# Physics-based prop on the highway. Props handle collisions
# with cars (because car's don't see props and just move through
# them) and slow them down based on the mass.


func _init() -> void:
    # enable contact monitoring
    contact_monitor = false
    max_contacts_reported = 3


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:

    for i in range(state.get_contact_count()):

        var other = state.get_contact_collider_object(i)

        # slow down cars only
        if not other is Car: continue
        var car := other as Car

        var impulse = state.get_contact_impulse(i)
        var normal = state.get_contact_local_normal(i)

        var force = impulse * normal

        # inspired by:
        # https://github.com/godotengine/godot/blob/bb08997b8725780670be30afa96354e7c38586fd/servers/physics_3d/godot_body_pair_3d.cpp#L402
        # https://github.com/godotengine/godot/blob/bb08997b8725780670be30afa96354e7c38586fd/servers/physics_3d/godot_body_3d.h#L227

        car.speed += force.z * -car.heading / car.mass
        car.steering += force.x / car.mass


