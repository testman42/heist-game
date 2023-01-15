extends DynamicObject
class_name Prop


func _on_collision(other: Node):
    # slow down cars
    if not other is Car: return
    var car := other as Car

    var totalMass := mass + car.mass
    var carPart := car.mass / totalMass

    var slowPart := 0.2
    var carSlowPart := slowPart * carPart

    car.speed *= 1 - carSlowPart
    car.steering *= 1 - carSlowPart
