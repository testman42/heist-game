extends DynamicObject
class_name Prop

# Physics-based prop on the highway. Props handle collisions
# with cars (because car's don't see props and just move through
# them) and slow them down based on the mass.


var previousVelocity := Vector3()


func _init() -> void:

    # enable contact monitoring
    contact_monitor = true
    max_contacts_reported = 3



func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:

    for i in range(state.get_contact_count()):

        var other = state.get_contact_collider_object(i)

        # slow down cars only
        if not other is Car: continue
        var car := other as Car

        # Delegate the resolution to the car's collision handler.
        # This body will be handled by the physics system.
        car.handleCollision(self, -state.get_contact_local_normal(i), state.get_contact_collider_position(i))


    # update previous
    previousVelocity = linear_velocity
