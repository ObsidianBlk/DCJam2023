extends CrawlTriggerNode3D


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	initialize_trigger()
	use_entity_direct_update(true)
	entity_changing.connect(_on_terminal_entity_changing)
	entity_changed.connect(_on_terminal_entity_changed)
	_on_terminal_entity_changed()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_terminal_entity_changing() -> void:
	if entity.interaction.is_connected(_on_terminal_interaction):
		entity.interaction.disconnect(_on_terminal_interaction)

func _on_terminal_entity_changed() -> void:
	if entity == null: return
	entity.set_block_all(false)
	entity.set_meta_value("visible_in_play", true)
	if not entity.interaction.is_connected(_on_terminal_interaction):
		entity.interaction.connect(_on_terminal_interaction)

func _on_terminal_interaction(entity : CrawlEntity) -> void:
	var pd : PlayerData = CrawlGlobals.Get_Player_Data()
	if pd == null: return
	if pd.get_fruit_count() >= 4:
		CrawlTriggerRelay.relay_request({"request":&"escaped"})
	else:
		CrawlTriggerRelay.relay_request({"request":&"dialog", "id":"need_fuit_escape"})
