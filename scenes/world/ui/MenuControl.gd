extends Control
class_name MenuControl

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req)

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _return_menu : String = ""

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func show_menu(menu_name : String, return_menu : String = "") -> void:
	visible = (name == menu_name)
	if visible:
		_return_menu = return_menu

func return_to() -> void:
	if _return_menu.is_empty() : return
	request.emit({"request":&"show_menu", "menu":_return_menu})

func has_return_menu() -> bool:
	return not _return_menu.is_empty()

