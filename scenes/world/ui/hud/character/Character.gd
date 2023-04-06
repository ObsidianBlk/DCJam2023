extends Control


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_range(0, 3, 1) var blober_index : int = 0:					set = set_blober_index
@export var benefit_description : String = "":		set = set_benefit_description

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _portrait : TextureRect = $Portrait
@onready var _health_bar : ProgressBar = $HealthBar
@onready var _label_benefit : Label = $Label_Benefit

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_blober_index(bi : int) -> void:
	if not (bi >= 0 and bi < 4): return
	if bi == blober_index: return
	blober_index = bi
	_UpdateBloberInfo()

func set_benefit_description(d : String) -> void:
	benefit_description = d

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not CrawlGlobals.player_data_loaded.is_connected(_on_player_data_loaded):
		CrawlGlobals.player_data_loaded.connect(_on_player_data_loaded)
	_on_player_data_loaded()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateBloberInfo() -> void:
	if _health_bar == null: return
	var pd : PlayerData = CrawlGlobals.Get_Player_Data()
	if pd == null: return
	_health_bar.value = pd.get_blob_health_percent(blober_index) * 100.0
	_label_benefit.text = benefit_description if pd.is_blob_active(blober_index) else ""
	# TODO: Figure out the portrait!

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_data_loaded() -> void:
	var pd : PlayerData = CrawlGlobals.Get_Player_Data()
	if pd == null: return
	if not pd.blob_added.is_connected(_on_blob_added):
		pd.blob_added.connect(_on_blob_added)
	if not pd.blob_hp_changed.is_connected(_on_blob_hp_changed):
		pd.blob_hp_changed.connect(_on_blob_hp_changed)
	if not pd.blob_dead.is_connected(_on_blob_dead):
		pd.blob_dead.connect(_on_blob_dead)
	_UpdateBloberInfo()

func _on_blob_added(idx : int) -> void:
	if idx != blober_index: return
	_UpdateBloberInfo()

func _on_blob_hp_changed(idx : int, hp : float, maxhp : float) -> void:
	if idx != blober_index or maxhp == 0.0: return
	_health_bar.value = (hp / maxhp) * 100.0

func _on_blob_dead(idx : int) -> void:
	if idx != blober_index: return
	_health_bar.value = 0
	# TODO: I don't know... something?
