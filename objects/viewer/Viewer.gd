extends CrawlEntityNode3D



# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const VIEW_LERP_RATE_DEFAULT : float = 0.25
const VIEW_LERP_RATE_STAIRS : float = 0.75

const CONFIG_SECTION_GAMEPLAY : String = "Gameplay"
const CONFIG_KEY_LOOK_TOWARDS_STAIRS : String = "look_toward_stairs"
const CONFIG_KEY_IGNORE_TRANSITIONS : String = "ignore_transitions"
const CONFIG_KEY_FOV : String = "fov"

const MIN_WAIT_TIME : float = 0.1
const MAX_WAIT_TIME : float = 0.4
const MIN_TURN_PROBABILITY : float = 0.1
const MAX_TURN_PROBABILITY : float = 0.9
enum STATE {FORWARD, MOVE_LOOK, TURN_LEFT, TURN_RIGHT, WAIT}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_range(0.0, 180.0) var max_yaw : float = 60.0
@export_range(0.0, 180.0) var rest_yaw : float = 30.0
@export_range(0.0, 180.0) var max_pitch : float = 30.0
@export_range(0.0, 180.0) var rest_pitch : float = 15.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _map_position : Vector3i = Vector3i.ZERO
var _freelook_enabled : bool = false

var _force_pitch : bool = false
var _forced_pitch_angle : float = 0.0
var _view_lerp_rate : float = VIEW_LERP_RATE_DEFAULT

var _look_toward_stairs : bool = true
var _ignore_transitions : bool = false

var _state : STATE = STATE.MOVE_LOOK
var _turn_prob : float = 0.1
var _waiting : bool = false

# ------------------------------------------------------------------------------
# Override Variables
# ------------------------------------------------------------------------------
@onready var _gimble_yaw_node : Node3D = $Facing/Gimble_Yaw
@onready var _gimble_pitch_node : Node3D = $Facing/Gimble_Yaw/Gimble_Pitch
@onready var _camera : Camera3D = $Facing/Gimble_Yaw/Gimble_Pitch/Camera3D

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	CrawlGlobals.crawl_config_loaded.connect(_on_config_changed)
	CrawlGlobals.crawl_config_reset.connect(_on_config_changed)
	CrawlGlobals.crawl_config_value_changed.connect(_on_config_value_changed)
	
	_ignore_transitions = CrawlGlobals.Get_Config_Value(CONFIG_SECTION_GAMEPLAY, CONFIG_KEY_IGNORE_TRANSITIONS, false)
	_look_toward_stairs = CrawlGlobals.Get_Config_Value(CONFIG_SECTION_GAMEPLAY, CONFIG_KEY_LOOK_TOWARDS_STAIRS, true)
	_camera.fov = CrawlGlobals.Get_Config_Value(CONFIG_SECTION_GAMEPLAY, CONFIG_KEY_FOV, 70.0)
	
	CrawlGlobals.editor_mode_changed.connect(_on_editor_mode_changed)
	_on_editor_mode_changed(CrawlGlobals.In_Editor_Mode())

func _process(delta : float) -> void:
	_SettleLookAngle(delta)
	if not is_transitioning() and entity != null:
		match _state:
			STATE.WAIT:
				if _waiting: return
				_waiting = true
				await get_tree().create_timer(randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)).timeout
				_state = STATE.MOVE_LOOK
				_waiting = false
			STATE.FORWARD:
				if entity.can_move(&"forward", true):
					_Move(&"forward")
					_state = STATE.WAIT
				else:
					_state = STATE.MOVE_LOOK
			STATE.TURN_LEFT:
				turn(COUNTERCLOCKWISE, _ignore_transitions)
				_state = STATE.WAIT
			STATE.TURN_RIGHT:
				turn(CLOCKWISE, _ignore_transitions)
				_state = STATE.WAIT
			STATE.MOVE_LOOK:
				var rng : Vector2 = Vector2.ZERO
				if entity.can_move(&"left", true):
					rng.x = -1.0
				if entity.can_move(&"right", true):
					rng.y = 1.0
				
				if entity.can_move(&"forward", true):
					if rng.length_squared() < 0.01 or randf() > _turn_prob:
						_turn_prob = min(MAX_TURN_PROBABILITY, _turn_prob + randf_range(0.01, 0.1))
						_state = STATE.FORWARD
						return
				
				_turn_prob = MIN_TURN_PROBABILITY
				if rng.length_squared() < 0.01:
					_state = STATE.TURN_LEFT if randf() < 0.5 else STATE.TURN_RIGHT
				else:
					var dir : float = randf_range(rng.x, rng.y)
					_state = STATE.TURN_LEFT if dir <= 0.0 else STATE.TURN_RIGHT


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _LerpLookAngle(deg : float, rest_deg : float) -> float:
	var target : float = rest_deg if _freelook_enabled else 0.0
	if abs(deg) > target:
		var sn : float = sign(deg)
		deg = lerp(deg, sn * target, VIEW_LERP_RATE_DEFAULT)
		if abs(deg) <= target + 0.01:
			return sn * target
	return deg

func _LerpLookAtAngle(deg : float, target : float) -> float:
	if abs(target - deg) <= 0.01: return deg
	return lerp(deg, target, VIEW_LERP_RATE_STAIRS)

func _SettleLookAngle(delta : float) -> void:
	_gimble_yaw_node.rotation_degrees.y = _LerpLookAngle(
		_gimble_yaw_node.rotation_degrees.y, rest_yaw
	)
	if _force_pitch:
		_gimble_pitch_node.rotation_degrees.x = _LerpLookAtAngle(
			_gimble_pitch_node.rotation_degrees.x, _forced_pitch_angle
		)
	_gimble_pitch_node.rotation_degrees.x = _LerpLookAngle(
		_gimble_pitch_node.rotation_degrees.x, rest_pitch
	)

func _Move(dir : StringName) -> void:
	move(dir, true, _ignore_transitions)

func _Interact() -> void:
	pass

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_config_changed(_section : String = "") -> void:
	_ignore_transitions = CrawlGlobals.Get_Config_Value(CONFIG_SECTION_GAMEPLAY, CONFIG_KEY_IGNORE_TRANSITIONS, false)
	_look_toward_stairs = CrawlGlobals.Get_Config_Value(CONFIG_SECTION_GAMEPLAY, CONFIG_KEY_LOOK_TOWARDS_STAIRS, true)
	if _camera != null:
		_camera.fov = CrawlGlobals.Get_Config_Value(CONFIG_SECTION_GAMEPLAY, CONFIG_KEY_FOV, 70.0)

func _on_config_value_changed(section : String, key : String, value : Variant) -> void:
	match section:
		CONFIG_SECTION_GAMEPLAY:
			match key:
				CONFIG_KEY_FOV:
					if typeof(value) == TYPE_FLOAT and value > 0.0:
						_camera.fov = value
				CONFIG_KEY_IGNORE_TRANSITIONS:
					if typeof(value) == TYPE_BOOL:
						_ignore_transitions = value
				CONFIG_KEY_LOOK_TOWARDS_STAIRS:
					if typeof(value) == TYPE_BOOL:
						_look_toward_stairs = value

func _on_editor_mode_changed(enabled : bool) -> void:
	var ref : MeshInstance3D = get_node_or_null("Reference")
	if ref != null:
		ref.visible = enabled
	if _camera != null:
		_camera.current = not enabled
	use_entity_direct_update(enabled)
	set_process(not enabled)
	if enabled:
		if transition_started.is_connected(_on_transition_started):
			transition_started.disconnect(_on_transition_started)
		if transition_complete.is_connected(_on_transition_completed):
			transition_complete.disconnect(_on_transition_completed)
	else:
		if not transition_started.is_connected(_on_transition_started):
			transition_started.connect(_on_transition_started)
		if not transition_complete.is_connected(_on_transition_completed):
			transition_complete.connect(_on_transition_completed)

func _on_transition_started(direction : StringName) -> void:
	match direction:
		&"up":
			_force_pitch = _look_toward_stairs
			_view_lerp_rate = VIEW_LERP_RATE_STAIRS
			_forced_pitch_angle = -max_pitch
		&"down":
			_force_pitch = _look_toward_stairs
			_view_lerp_rate = VIEW_LERP_RATE_STAIRS
			_forced_pitch_angle = max_pitch

func _on_transition_completed() -> void:
	_force_pitch = false
	if entity == null: return
	if _entity_direct_update: return
	if entity.can_move(&"down"):
		# TODO: Technically I should check for a ladder, but not ready for that yet!
		#   So we'll just fall!
		clear_movement_queue()
		move(&"down")
