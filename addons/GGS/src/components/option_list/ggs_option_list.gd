extends OptionButton
class_name ggsOptionList

export(int, 0, 99) var setting_index: int
var script_instance: Object


func _ready() -> void:
    # Load value
    var current = ggsManager.settings_data[str(setting_index)]["current"]
    selected = current["value"]

    # Load script
    var script: Script = load(ggsManager.settings_data[str(setting_index)]["logic"])
    script_instance = script.new()

    # Connect signal
    connect("item_selected", self, "_on_item_selected")
    connect("mouse_entered", self, "_on_mouse_entered")


func reset_to_default() -> void:
    var default = ggsManager.settings_data[str(setting_index)]["default"]
    _on_item_selected(default["value"])
    selected = default["value"]


func _on_item_selected(index: int) -> void:
    var current = ggsManager.settings_data[str(setting_index)]["current"]
    current["value"] = index
    script_instance.main(current)

    # do not save when running the game in the editor
    if not OS.has_feature('editor'):
       ggsManager.save_settings_data()


# Handle mouse focus
func _on_mouse_entered() -> void:
    grab_focus()
