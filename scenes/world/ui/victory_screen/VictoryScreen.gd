extends MenuControl


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _button : Button = $Announcement/Button


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_button_pressed():
	visible = false
	CrawlTriggerRelay.relay_request({"request":&"quit_game"})

func _on_visibility_changed():
	if visible and _button != null:
		_button.grab_focus()
