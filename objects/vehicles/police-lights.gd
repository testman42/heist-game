extends Breakable
class_name PoliceLights

# Makes police lights blink and stop blinking when broken off.

@export var blueLight: Material
@export var blueLightActive: Material
@export var redLight: Material
@export var redLightActive: Material

var isActive := true


func breakOff() -> void:
    stop()
    super()


func stop() -> void:
    isActive = false

    $timer.free()
    $model/red.material = redLight
    $model/red/bulb.visible = false
    $model/blue.material = blueLight
    $model/blue/bulb.visible = false


# called by the toggle timer to switch between red and blue lights
func toggle() -> void:

    if not isActive: return

    if $model/red.material == redLight:
        $model/red.material = redLightActive
        $model/red/bulb.visible = true
        $model/blue.material = blueLight
        $model/blue/bulb.visible = false
    else:
        $model/red.material = redLight
        $model/red/bulb.visible = false
        $model/blue.material = blueLightActive
        $model/blue/bulb.visible = true

