extends Control

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_REQUEST : String = "request"
const META_KEY_ID : String = "ID"


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var entity : CrawlEntity = null:				set = set_entity

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _lineedit_request : LineEdit = $LineEdit_Request
@onready var _lineedit_id : LineEdit = $LineEdit_ID

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
func set_entity(e : CrawlEntity) -> void:
	if e != entity:
		entity = e
		_UpdateControls()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateControls()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateControls() -> void:
	if _lineedit_request == null or _lineedit_id == null or entity == null: return
	_lineedit_request.text = ""
	_lineedit_id.text = ""
	if entity.has_meta_key(META_KEY_REQUEST):
		var val = entity.get_meta_value(META_KEY_REQUEST)
		if typeof(val) == TYPE_STRING_NAME:
			_lineedit_request.text = String(val)
	if entity.has_meta_key(META_KEY_ID):
		var val = entity.get_meta_value(META_KEY_ID)
		if typeof(val) == TYPE_STRING:
			_lineedit_id.text = val


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_line_edit_request_text_submitted(new_text : String) -> void:
	if entity == null: return
	if new_text.is_empty():
		entity.erase_meta_key(META_KEY_REQUEST)
	else:
		entity.set_meta_value(META_KEY_REQUEST, StringName(new_text))

func _on_line_edit_id_text_submitted(new_text : String) -> void:
	if entity == null: return
	if new_text.is_empty():
		entity.erase_meta_key(META_KEY_ID)
	else:
		entity.set_meta_value(META_KEY_ID, new_text)
