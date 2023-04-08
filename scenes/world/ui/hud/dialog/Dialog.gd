extends Control

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DIALOG : Dictionary = {
	"outside_toxic":[
		"The ship... it crashed. Just barely had time to get to this escape pod. I saw other pods eject along with mine. Maybe there are others who made it out.",
		"I cannot breath! The atmosphere seems toxic. I'll sufficate if I stay on this world for too long! There has got to be a way out!",
		"Perhaps one of the ships shuttles is intact somewhere! Damn this atmosphere! Let's see if I don't sufficate before I find something!",
		"[ Press F to interact or attack ]"
	],
	"oxygen_fruit":[
		"This looks like a fruit of some kind. According to my analizer, it contains a high concentration of oxygen. I wonder if...",
		"Yes... it seems I can process a fruit into a little extra oxygen in my tanks! Too bad I only have a basic oxygen processing unit. Doesn't make much. Still... better than nothing. Maybe there's more fruits?",
		"[ Press R to consume any fruit picked up ]"
	],
	"survivor_oxy":[
		"Thank goodness! My oxygen tank was on the verge of failing. I know it will be an issue for us both to use the same oxygen supply but...",
		"I have a working CO2 scrubber Mk-V unit. This should make whatever oxygen you have last quite a bit longer even with the two of us."
	],
	"survivor_def":[
		"Good, you found me. I did not have the oxygen to leave my pod alone.",
		"I did manage to salvage some armor from the ship before it went down. Good thing too! These plants are vicious!"
	],
	"survivor_eng":[
		"Excellent! There was little I could do with this hunk of junk and I would have not been able to handle the plantlife on this rock!",
		"Get me to an escape shuttle and I can fly us out of here!"
	],
	
	"need_fuit_escape":[
		"SYSTEM ERROR: More oxygen needed in fuel tanks",
		"...",
		"Perhaps if we had 4 or more fruits the system could process the oxygen from them and we can escape?"
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
@onready var _button : Button = $Layout/HBoxContainer/Button

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
	_button.grab_focus()
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
			if typeof(req["id"]) != TYPE_STRING_NAME and typeof(req["id"]) != TYPE_STRING: return
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
