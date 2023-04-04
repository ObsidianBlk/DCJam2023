extends Node3D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFAULT_MENU_DUNGEON : String = "res://dungeons/Menu_Map_001.tres"

const FIRST_DUNGEON : String = "res://dungeons/CrashedPod.tres"

const DUNGEON : PackedScene = preload("res://scenes/dungeon/Dungeon.tscn")

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _dungeon_object : Node3D = null

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
	MusicBox.add_music_track("rise", "res://assets/audio/music/rise_of_the_early_dawn.ogg", false)
	
	_dungeon_object = DUNGEON.instantiate()
	_dungeon_object.viewer_mode = true
	add_child(_dungeon_object)
	_dungeon_object.load_dungeon(DEFAULT_MENU_DUNGEON)
	
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
		&"start_game":
			_dungeon_object.viewer_mode = false
			_dungeon_object.load_dungeon(FIRST_DUNGEON)
			_ui.show_menu("")
