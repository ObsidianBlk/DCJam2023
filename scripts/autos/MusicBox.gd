extends Node


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal music_finished(title)

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _music : Dictionary = {}
var _player : WeakRef = weakref(null)
var _fade_time : float = 0.5

var _min_track_delay : float = 1.0
var _max_track_delay : float = 6.0
var _play_continuous : bool = false

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlGlobals.crawl_config_loaded.connect(_on_config_reset)
	CrawlGlobals.crawl_config_reset.connect(_on_config_reset)
	CrawlGlobals.crawl_config_value_changed.connect(_on_config_value_changed)
	CrawlGlobals.Register_Config_Section_Handler("Audio", (func(config : ConfigFile, section : String, only_if_missing : bool = false):
		if config == null: return
		if section.is_empty(): return
		if not config.has_section_key(section, "master_volume") or not only_if_missing:
			config.set_value(section, "master_volume", 1.0)
		if not config.has_section_key(section, "music_volume") or not only_if_missing:
			config.set_value(section, "music_volume", 1.0)
		if not config.has_section_key(section, "sfx_volume") or not only_if_missing:
			config.set_value(section, "sfx_volume", 1.0)), true)
	_on_config_reset()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _FadeTo(player : AudioStreamPlayer, from_volume : float, to_volume : float) -> int:
	player.volume_db = from_volume
	var tween : Tween = create_tween()
	tween.tween_property(player, "volume_db", to_volume, _fade_time)
	await tween.finished
	return OK

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func assign_player(player : AudioStreamPlayer) -> void:
	var old_player : AudioStreamPlayer = _player.get_ref()
	if old_player != null:
		if old_player.finished.is_connected(_on_player_finished):
			old_player.finished.disconnect(_on_player_finished)
	_player = weakref(player)
	if player != null:
		if not player.finished.is_connected(_on_player_finished):
			player.finished.connect(_on_player_finished)

func add_music_track(title: String, music_filepath : String, autoplay : bool = false) -> void:
	if title in _music: return
	_music[title] = {"src":music_filepath, "stream":null}
	if autoplay:
		play(title)

func play_random() -> void:
	if _music.is_empty(): return
	if _music.size() > 1:
		var cur_title : String = get_playing_title()
		var idx : int = randi_range(0, _music.size())
		var title : String = _music.keys()[idx]
		if cur_title == title:
			play_random()
		play(title)
	else:
		play(_music.keys()[0])

func play(title : String) -> void:
	if not title in _music: return
	var player : AudioStreamPlayer = _player.get_ref()
	if player == null: return
	
	if _music[title]["stream"] == null:
		var stream = load(_music[title]["src"])
		if not is_instance_of(stream, AudioStream):
			printerr("Failed to load music stream from \"", _music[title]["src"], "\".")
			return
		_music[title]["stream"] = stream
	
	if player.stream == _music[title]["stream"]:
		if player.stream_paused:
			player.stream_paused = false
			return
		player.play()
		_FadeTo(player, linear_to_db(0.0), linear_to_db(1.0))
	elif player.stream != null:
		if player.playing:
			var _res : int = await _FadeTo(player, player.volume_db, linear_to_db(0.0))
			player.stop()
		player.stream = _music[title]["stream"]
		player.play()
		_FadeTo(player, player.volume_db, linear_to_db(1.0))
	else:
		player.stream = _music[title]["stream"]
		player.play()
		_FadeTo(player, player.volume_db, linear_to_db(1.0))

func pause() -> void:
	var player : AudioStreamPlayer = _player.get_ref()
	if player == null: return
	if player.stream == null: return
	player.stream_paused = true

func resume() -> void:
	var player : AudioStreamPlayer = _player.get_ref()
	if player == null: return
	if player.stream == null: return
	player.stream_paused = false

func is_playing() -> bool:
	if _player.get_ref() == null: return false
	return _player.get_ref().playing

func get_playing_title(include_not_playing : bool = false) -> String:
	var player : AudioStreamPlayer = _player.get_ref()
	if player == null: return ""
	if player.stream == null: return ""
	if not include_not_playing and not player.playing: return ""
	for title in _music:
		if _music[title]["stream"] == player.stream:
			return title
	return ""


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_config_reset(section : String = "") -> void:
	var value : float = CrawlGlobals.Get_Config_Value("Audio", "master_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	value = CrawlGlobals.Get_Config_Value("Audio", "music_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	value = CrawlGlobals.Get_Config_Value("Audio", "sfx_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_config_value_changed(section : String, key : String, value : Variant) -> void:
	if section != "Audio": return
	match key:
		"master_volume":
			if typeof(value) == TYPE_FLOAT:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		"music_volume":
			if typeof(value) == TYPE_FLOAT:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
		"sfx_volume":
			if typeof(value) == TYPE_FLOAT:
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))


func _on_player_finished() -> void:
	music_finished.emit(get_playing_title(true))
	if _play_continuous:
		var delay : float = randf_range(_min_track_delay, _max_track_delay)
		var timer : SceneTreeTimer = get_tree().create_timer(delay)
		await timer.timeout
		play_random()

