extends MenuControl


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _progress_oxy : ProgressBar = %Progress_OXY

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlGlobals.player_data_loaded.connect(_on_player_data_loaded)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_data_loaded() -> void:
	var pd : PlayerData = CrawlGlobals.Get_Player_Data()
	if pd == null: return
	if not pd.oxy_changed.is_connected(_on_oxy_changed):
		pd.oxy_changed.connect(_on_oxy_changed)

func _on_oxy_changed(oxy : float, maxoxy : float) -> void:
	if maxoxy == 0.0:
		_progress_oxy.value = 0.0
	else:
		_progress_oxy.value = (oxy / maxoxy) * 100.0
