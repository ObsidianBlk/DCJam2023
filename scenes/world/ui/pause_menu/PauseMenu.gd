extends MenuControl


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _resume : Button = $Panel/Layout/Resume


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_visibility_changed() -> void:
	if visible and _resume != null:
		_resume.grab_focus()

func _on_resume_pressed():
	request.emit({"request":&"pause_game"})

func _on_options_pressed():
	request.emit({"request":&"show_menu", "return":&"PauseMenu", "menu":&"OptionsMenu"})

func _on_quit_main_pressed():
	request.emit({"request":&"quit_game"})

func _on_quit_pressed():
	request.emit({"request":&"quit_application"})
