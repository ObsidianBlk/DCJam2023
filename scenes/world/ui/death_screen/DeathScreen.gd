extends MenuControl


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_button_pressed():
	visible = false
	CrawlTriggerRelay.relay_request({"request":&"quit_game"})
