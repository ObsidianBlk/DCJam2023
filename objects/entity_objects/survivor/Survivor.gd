extends CrawlEntityNode3D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_BLOB_INDEX : String = "blob_index"
const META_KEY_DIALOG_ID : String = "dialog_id"

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlGlobals.editor_mode_changed.connect(_on_editor_mode_changed)
	entity_changed.connect(_on_entity_changed)
	entity_changing.connect(_on_entity_changing)
	if entity != null:
		_on_entity_changed(entity)
	_on_editor_mode_changed(CrawlGlobals.In_Editor_Mode())

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_editor_mode_changed(enabled : bool) -> void:
	if entity == null: return
	if enabled:
		_on_entity_changing(entity)
	else:
		_on_entity_changed(entity)

func _on_entity_changing(entity : CrawlEntity) -> void:
	if entity == null: return
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.disconnect(_on_focus_position_changed)

func _on_entity_changed(entity : CrawlEntity) -> void:
	if entity == null: return
	entity.set_block_all(false)
	if not entity.has_meta_key(META_KEY_BLOB_INDEX):
		entity.set_meta_value(META_KEY_BLOB_INDEX, 1)
	
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if not map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.connect(_on_focus_position_changed)

func _on_focus_position_changed(focus_position : Vector3i) -> void:
	if entity == null: return
	if not entity.has_meta_key(META_KEY_BLOB_INDEX): return
	if focus_position == entity.position:
		var pd : PlayerData = CrawlGlobals.Get_Player_Data()
		if pd == null: return
		pd.add_blob(entity.get_meta_value(META_KEY_BLOB_INDEX))
		if entity.has_meta_key(META_KEY_DIALOG_ID):
			CrawlTriggerRelay.relay_request({
				"request":&"dialog",
				"id":entity.get_meta_value(META_KEY_DIALOG_ID)
			})
		
		var map : CrawlMap = entity.get_map()
		if map == null:
			queue_free.call_deferred()
			return
		map.remove_entity.call_deferred(entity)
