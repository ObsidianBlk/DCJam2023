extends MenuControl

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_start : Button = $Panel/Layout/Start

# ------------------------------------------------------------------------------
# Handlers
# ------------------------------------------------------------------------------
func _on_visibility_changed():
	if visible and _btn_start != null:
		_btn_start.grab_focus()

func _on_start_pressed():
	request.emit({"request":&"start_game"})

func _on_options_pressed():
	request.emit({"request":&"show_menu", "menu":&"OptionsMenu"})

func _on_quit_pressed():
	request.emit({"request":&"quit_application"})



