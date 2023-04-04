extends MenuControl


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _section_audio = %SectionAudio
@onready var _section_graphics = %SectionGraphics
@onready var _section_gameplay = %SectionGameplay

@onready var _gameplay : Control = $Margins/Gameplay
@onready var _audio : Control = $Margins/Audio
@onready var _graphics : Control = $Margins/Graphics

@onready var _hslider_master : HSlider = %HSlider_Master
@onready var _hslider_sfx : HSlider = %HSlider_SFX
@onready var _hslider_music : HSlider = %HSlider_Music

@onready var _ignore_transition : CheckButton = %IgnoreTransition
@onready var _look_stairs : CheckButton = %LookStairs
@onready var _hslider_fov : HSlider = %HSlider_FOV
@onready var _label_fov_value : Label = %Label_FOV_Value


@onready var _ssao : CheckButton = $Margins/Graphics/Layout/SSAO
@onready var _ssil : CheckButton = $Margins/Graphics/Layout/SSIL


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	
	CrawlGlobals.crawl_config_loaded.connect(_on_config_reset)
	CrawlGlobals.crawl_config_reset.connect(_on_config_reset)
	CrawlGlobals.crawl_config_value_changed.connect(_on_config_value_changed)
	
	_hslider_master.value_changed.connect(_on_audio_slider_value_changed.bind("master_volume"))
	_hslider_music.value_changed.connect(_on_audio_slider_value_changed.bind("music_volume"))
	_hslider_sfx.value_changed.connect(_on_audio_slider_value_changed.bind("sfx_volume"))
	
	_ignore_transition.toggled.connect(_on_button_toggled.bind("Gameplay", "ignore_transitions"))
	_look_stairs.toggled.connect(_on_button_toggled.bind("Gameplay", "look_toward_stairs"))
	_hslider_fov.value_changed.connect(_on_fov_slider_value_changed)
	
	_ssao.toggled.connect(_on_button_toggled.bind("Graphics", "SSAO"))
	_ssil.toggled.connect(_on_button_toggled.bind("Graphics", "SSIL"))
	_on_config_reset()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _audio.visible:
			_audio.visible = false
			_section_audio.grab_focus()
		elif _graphics.visible:
			_graphics.visible = false
			_section_graphics.grab_focus()
		elif _gameplay.visible:
			_gameplay.visible = false
			_section_gameplay.grab_focus()
		else:
			request.emit({"request":&"show_menu", "menu":&"MainMenu"})
		accept_event()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_visibility_changed() -> void:
	if visible == true:
		_section_audio.grab_focus()

func _on_config_reset(section : String = "") -> void:
	_on_config_value_changed("Audio", "master_volume",
		CrawlGlobals.Get_Config_Value("Audio", "master_volume", 1.0))
	_on_config_value_changed("Audio", "music_volume",
		CrawlGlobals.Get_Config_Value("Audio", "music_volume", 1.0))
	_on_config_value_changed("Audio", "sfx_volume",
		CrawlGlobals.Get_Config_Value("Audio", "sfx_volume", 1.0))
	
	_on_config_value_changed("Gameplay", "ignore_transitions",
		CrawlGlobals.Get_Config_Value("Gameplay", "ignore_transitions", false))
	_on_config_value_changed("Gameplay", "look_toward_stairs",
		CrawlGlobals.Get_Config_Value("Gameplay", "look_toward_stairs", true))
	_on_config_value_changed("Gameplay", "fov",
		CrawlGlobals.Get_Config_Value("Gameplay", "fov", 70.0))
	
	_on_config_value_changed("Graphics", "SSAO",
		CrawlGlobals.Get_Config_Value("Graphics", "SSAO", true))
	_on_config_value_changed("Graphics", "SSIL",
		CrawlGlobals.Get_Config_Value("Graphics", "SSIL", true))


func _on_config_value_changed(section : String, key : String, value : Variant) -> void:
	match section:
		"Gameplay":
			match key:
				"ignore_transitions":
					if typeof(value) == TYPE_BOOL:
						_ignore_transition.button_pressed = value
				"look_toward_stairs":
					if typeof(value) == TYPE_BOOL:
						_look_stairs.button_pressed = value
				"fov":
					if typeof(value) == TYPE_FLOAT:
						_hslider_fov.value = value
						_label_fov_value.text = "%d"%[floor(value)]
		"Graphics":
			match key:
				"SSAO":
					if typeof(value) == TYPE_BOOL:
						_ssao.button_pressed = value
				"SSIL":
					if typeof(value) == TYPE_BOOL:
						_ssil.button_pressed = value
		"Audio":
			match key:
				"master_volume":
					if typeof(value) == TYPE_FLOAT:
						_hslider_master.value = value * 100
				"music_volume":
					if typeof(value) == TYPE_FLOAT:
						_hslider_music.value = value * 100
				"sfx_volume":
					if typeof(value) == TYPE_FLOAT:
						_hslider_sfx.value = value * 100

func _on_audio_slider_value_changed(value : float, key : String) -> void:
	CrawlGlobals.Set_Config_Value("Audio", key, value / 100.0)

func _on_fov_slider_value_changed(value : float) -> void:
	_label_fov_value.text = "%d"%[floor(value)]
	CrawlGlobals.Set_Config_Value("Gameplay", "fov", value)

func _on_button_toggled(button_pressed : bool, section : String, key : String) -> void:
	CrawlGlobals.Set_Config_Value(section, key, button_pressed)

func _on_section_audio_pressed() -> void:
	_audio.visible = not _audio.visible
	if _audio.visible:
		_hslider_master.grab_focus()

func _on_section_graphics_pressed() -> void:
	_graphics.visible = not _graphics.visible
	if _graphics.visible:
		_ssao.grab_focus()

func _on_section_gameplay_pressed() -> void:
	_gameplay.visible = not _gameplay.visible
	if _gameplay.visible:
		_ignore_transition.grab_focus()

func _on_apply_pressed():
	CrawlGlobals.Save_Config()

func _on_reset_pressed():
	CrawlGlobals.Reset_Config()

func _on_back_pressed():
	request.emit({"request":&"show_menu", "menu":&"MainMenu"})
