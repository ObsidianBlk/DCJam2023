extends CrawlEntityNode3D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_DIALOG_ID : String = "dialog_id"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _dead : bool = false

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlGlobals.editor_mode_changed.connect(_on_editor_mode_changed)
	entity_changed.connect(_on_entity_changed)
	entity_changing.connect(_on_entity_changing)
	if entity != null:
		_on_entity_changed()
	_on_editor_mode_changed(CrawlGlobals.In_Editor_Mode())

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_editor_mode_changed(enabled : bool) -> void:
	if entity == null: return
	if enabled:
		_on_entity_changing()
	else:
		_on_entity_changed()

func _on_entity_changing() -> void:
	if entity == null: return
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.disconnect(_on_focus_position_changed)

func _on_entity_changed() -> void:
	if entity == null: return
	entity.set_block_all(false)

	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if not map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.connect(_on_focus_position_changed)

func _on_focus_position_changed(focus_position : Vector3i) -> void:
	if entity == null or _dead: return
	if focus_position == entity.position:
		var pd : PlayerData = CrawlGlobals.Get_Player_Data()
		if pd == null: return
		_dead = true
		pd.add_fruit(1)
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
	
