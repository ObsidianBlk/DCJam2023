extends CrawlEntityNode3D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_DUNGEON_NAME : String = "dungeon_name"

const DUNGEON_BASE_PATH : String = "res://dungeons/"

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
	visible = enabled

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
	if entity == null: return
	if not entity.has_meta_key(META_KEY_DUNGEON_NAME): return
	if focus_position == entity.position:
		var dname = entity.get_meta_value(META_KEY_DUNGEON_NAME)
		if typeof(dname) != TYPE_STRING: return
		if dname.is_empty(): return
		CrawlTriggerRelay.relay_request.call_deferred({
			"request":&"level_transition",
			"src":"%s%s.tres"%[DUNGEON_BASE_PATH, dname]
		})
