extends Node3D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CONFIG_PATH : String = "user://crawl.ini"

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
@onready var _game : Node3D = $Game


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlTriggerRelay.request.connect(_on_request)
	MusicBox.assign_player(_asp_music)
	MusicBox.add_music_track("rise", "res://assets/audio/music/rise_of_the_early_dawn.ogg", true)
	
	if CrawlGlobals.Load_Config(CONFIG_PATH) != OK:
		CrawlGlobals.Reset_Config()
		CrawlGlobals.Save_Config(CONFIG_PATH)
	
	_dungeon_object = DUNGEON.instantiate()
	_dungeon_object.viewer_mode = true
	_game.add_child(_dungeon_object)
	_dungeon_object.load_dungeon(DEFAULT_MENU_DUNGEON)
	
	_ui.request.connect(_on_request)
	_ui.show_menu("MainMenu")


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _PauseGame() -> void:
	if not Scheduler.is_prime_active():
		if not Scheduler.primary_entity_active.is_connected(_PauseGame):
			Scheduler.primary_entity_active.connect(_PauseGame, CONNECT_ONE_SHOT)
		return
	get_tree().paused = true
	_ui.show_menu("PauseMenu")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_request(req : Dictionary) -> void:
	if not "request" in req: return
	match req["request"]:
		&"quit_application":
			get_tree().quit()
		&"quit_game":
			if CrawlGlobals.Get_Player_Data() == null: return
			if get_tree().paused:
				get_tree().paused = false
			CrawlGlobals.Destroy_Player_Data()
			_dungeon_object.viewer_mode = true
			_dungeon_object.load_dungeon(DEFAULT_MENU_DUNGEON)
			_ui.show_menu("MainMenu")
		&"start_game":
			if CrawlGlobals.Get_Player_Data() != null: return
			CrawlGlobals.Create_New_Player_Data()
			_dungeon_object.viewer_mode = false
			_dungeon_object.load_dungeon(FIRST_DUNGEON)
			_ui.show_menu("HUD")
		&"level_transition":
			if CrawlGlobals.Get_Player_Data() == null: return
			if not "src" in req: return
			if typeof(req["src"]) != TYPE_STRING: return
			Scheduler.primary_entity_deactive.connect(
				(func() : _dungeon_object.load_dungeon(req["src"])),
				CONNECT_ONE_SHOT
			)
		&"pause_game":
			if CrawlGlobals.Get_Player_Data() == null: return
			if get_tree().paused:
				_ui.show_menu("HUD")
				get_tree().paused = false
			else:
				_PauseGame()
