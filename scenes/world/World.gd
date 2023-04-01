extends Node3D


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _ui : CanvasLayer = $UI
@onready var _asp_music : AudioStreamPlayer = $ASP_Music


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	MusicBox.assign_player(_asp_music)
	MusicBox.add_music_track("rise", "res://assets/audio/music/rise_of_the_early_dawn.ogg", true)
	_ui.request.connect(_on_ui_request)
	_ui.show_menu("MainMenu")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_ui_request(req : Dictionary) -> void:
	if not "request" in req: return
	match req["request"]:
		&"quit_application":
			get_tree().quit()
