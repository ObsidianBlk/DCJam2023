extends Control

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DIALOG : Dictionary = {
	"survivor_oxy":[
		"Thank goodness! My oxygen tank was on the verge of failing. I know it will be an issue for us both to use the same oxygen supply but...",
		"I have a working CO2 scrubber Mk-V unit. This should make whatever oxygen you have last quite a bit longer even with the two of us."
	]
}

const CHAR_PER_SECOND : float = 100.0
# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active_dialog : StringName = &""
var _line_id : int = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _label_dialog : Label = %Label_Dialog

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlTriggerRelay.request.connect(_on_request)
	visible = false

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ProcessLine() -> void:
	_label_dialog.text = DIALOG[_active_dialog][_line_id]
	_label_dialog.visible_ratio = 0.0
	var duration : float = float(_label_dialog.text.length()) / CHAR_PER_SECOND
	var _tween : Tween = create_tween()
	_tween.tween_property(_label_dialog, "visible_ratio", 1.0, duration)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_request(req : Dictionary) -> void:
	if not "request" in req: return
	match req["request"]:
		&"dialog":
			if not "id" in req: return
			if typeof(req["id"]) != TYPE_STRING_NAME: return
			if not req["id"] in DIALOG: return
			_active_dialog = req["id"]
			_line_id = 0
			visible = true
			_ProcessLine()
			

func _on_button_pressed():
	if _label_dialog.visible_ratio < 1.0:
		_label_dialog.visible_ratio = 1.0
	else:
		_line_id += 1
		if _line_id < DIALOG[_active_dialog].size():
			_ProcessLine()
		else:
			_active_dialog = &""
			_line_id = 0
			visible = false
