extends CrawlEntityNode3D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_REQUEST : String = "request"
const META_KEY_ID : String = "ID"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _triggered : bool = false

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlGlobals.editor_mode_changed.connect(_on_editor_mode_changed)
	entity_changed.connect(_on_entity_changed)
	entity_changing.connect(_on_entity_changing)
#	if entity != null:
#		_on_entity_changed()
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
	keep_hidden(not enabled)

func _on_entity_changing() -> void:
	if entity == null: return
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.disconnect(_on_focus_position_changed)

func _on_entity_changed() -> void:
	if entity == null: return
	_triggered = false
	entity.set_block_all(false)
	
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if not map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.connect(_on_focus_position_changed)

func _on_focus_position_changed(focus_position : Vector3i) -> void:
	if entity == null or _triggered: return
	if not entity.has_meta_key(META_KEY_REQUEST): return
	if focus_position == entity.position:
		var req_name = entity.get_meta_value(META_KEY_REQUEST)
		if typeof(req_name) != TYPE_STRING_NAME: return
		if req_name == &"": return
		var id = entity.get_meta_value(META_KEY_ID, &"")
		var req : Dictionary = {"request":req_name}
		if typeof(id) == TYPE_STRING:
			req["id"] = id
		_triggered = true
		CrawlTriggerRelay.relay_request.call_deferred(req)
