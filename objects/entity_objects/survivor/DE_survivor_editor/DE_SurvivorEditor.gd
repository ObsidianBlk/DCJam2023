extends Control

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_BLOB_INDEX : String = "blob_index"
const META_KEY_DIALOG_ID : String = "dialog_id"


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var entity : CrawlEntity = null:				set = set_entity


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _hslider_bi : HSlider = %HSlider_BI
@onready var _label_bi : Label = %Label_BI
@onready var _lineedit_dialogid : LineEdit = %LineEdit_DialogID


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
	if _hslider_bi == null or _lineedit_dialogid == null: return
	if entity == null: return
	if entity.has_meta_key(META_KEY_BLOB_INDEX):
		var value = entity.get_meta_value(META_KEY_BLOB_INDEX)
		if typeof(value) != TYPE_INT or not (value >= 1 and value <= 3):
			entity.set_meta_value(META_KEY_BLOB_INDEX, int(_hslider_bi.value))
		else:
			_hslider_bi.value = value
			_label_bi.text = "%d"%[value]
	if entity.has_meta_key(META_KEY_DIALOG_ID):
		var value = entity.get_meta_value(META_KEY_DIALOG_ID)
		if typeof(value) != TYPE_STRING_NAME:
			_lineedit_dialogid.text = ""
			entity.erase_meta_key(META_KEY_DIALOG_ID)
		else:
			_lineedit_dialogid.text = entity.get_meta_value(META_KEY_DIALOG_ID)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_h_slider_bi_value_changed(value : float):
	var val : int = int(value)
	_label_bi.text = "%d"%[val]
	if entity == null: return
	entity.set_meta_value(META_KEY_BLOB_INDEX, val)

func _on_line_edit_dialog_id_text_submitted(new_text : String):
	if entity == null: return
	if new_text.is_empty():
		entity.erase_meta_key(META_KEY_DIALOG_ID)
	else:
		entity.set_meta_value(META_KEY_DIALOG_ID, StringName(new_text))
