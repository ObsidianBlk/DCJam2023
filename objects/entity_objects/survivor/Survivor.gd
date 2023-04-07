extends CrawlEntityNode3D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_BLOB_INDEX : String = "blob_index"
const META_KEY_DIALOG_ID : String = "dialog_id"

const BLOB_1_TEXTURE : Texture = preload("res://assets/textures/oxygenman.png")
const BLOB_2_TEXTURE : Texture = preload("res://assets/textures/DEF_man.png")
const BLOB_3_TEXTURE : Texture = preload("res://assets/textures/Engineer_man.png")

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite : Sprite3D = $Sprite3D


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
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateTexture() -> void:
	if entity == null: return
	var idx = entity.get_meta_value(META_KEY_BLOB_INDEX, 1)
	if typeof(idx) == TYPE_INT:
		match idx:
			1:
				_sprite.texture = BLOB_1_TEXTURE
			2:
				_sprite.texture = BLOB_2_TEXTURE
			3:
				_sprite.texture = BLOB_3_TEXTURE


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
	
	if entity.meta_value_changed.is_connected(_on_survivor_meta_value_changed):
		entity.meta_value_changed.disconnect(_on_survivor_meta_value_changed)
	
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.disconnect(_on_focus_position_changed)

func _on_entity_changed() -> void:
	if entity == null: return
	entity.set_block_all(false)
	if not entity.has_meta_key(META_KEY_BLOB_INDEX):
		entity.set_meta_value(META_KEY_BLOB_INDEX, 1)
	
	if not entity.meta_value_changed.is_connected(_on_survivor_meta_value_changed):
		entity.meta_value_changed.connect(_on_survivor_meta_value_changed)
	
	_UpdateTexture()
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	if not map.focus_position_changed.is_connected(_on_focus_position_changed):
		map.focus_position_changed.connect(_on_focus_position_changed)

func _on_survivor_meta_value_changed(key : String) -> void:
	_UpdateTexture()

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
