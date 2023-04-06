extends Control


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_DUNGEON_NAME : String = "dungeon_name"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var entity : CrawlEntity = null:				set = set_entity


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _lineedit_dn : LineEdit = %LineEdit_DN


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
	if _lineedit_dn == null: return
	if entity == null: return
	if entity.has_meta_key(META_KEY_DUNGEON_NAME):
		var dname = entity.get_meta_value(META_KEY_DUNGEON_NAME)
		if typeof(dname) != TYPE_STRING:
			_lineedit_dn.text = ""
		else:
			_lineedit_dn.text = dname

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_line_edit_dn_text_submitted(new_text : String) -> void:
	if entity == null: return
	if new_text.is_valid_filename():
		entity.set_meta_value(META_KEY_DUNGEON_NAME, new_text)
	else:
		_lineedit_dn.text = entity.get_meta_value(META_KEY_DUNGEON_NAME, "")
