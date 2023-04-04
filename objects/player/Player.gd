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

func _unhandled_input(event : InputEvent) -> void:
	if _freelook_enabled:
		if is_instance_of(event, InputEventMouseMotion):
			var ppd : float = 400.0 # TODO: Make this a const or an export.
			_gimble_yaw_node.rotation_degrees.y = clamp(
				_gimble_yaw_node.rotation_degrees.y + (-event.velocity.x / ppd),
				-max_yaw, max_yaw
			)
			_gimble_pitch_node.rotation_degrees.x = clamp(
				_gimble_pitch_node.rotation_degrees.x + (event.velocity.y / ppd),
				-max_pitch, max_pitch
			)
		else:
			if event.is_action("freelook_up") or event.is_action("freelook_down"):
				var strength : float = event.get_action_strength("freelook_up") - event.get_action_strength("freelook_down")
				_gimble_pitch_node.rotation_degrees.x = strength * rest_pitch
			elif event.is_action("freelook_left") or event.is_action("freelook_right"):
				var strength : float = event.get_action_strength("freelook_left") - event.get_action_strength("freelook_right")
				_gimble_yaw_node.rotation_degrees.y = strength * rest_yaw
	
	if event.is_action("free_look"):
		_freelook_enabled = event.is_pressed()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _freelook_enabled else Input.MOUSE_MODE_VISIBLE
	if entity != null:
		if event.is_action_pressed("move_foreward"):
			move(&"foreward", false, _ignore_transitions)
		if event.is_action_pressed("move_backward"):
			move(&"backward", false, _ignore_transitions)
		if event.is_action_pressed("move_left"):
			move(&"left", false, _ignore_transitions)
		if event.is_action_pressed("move_right"):
			move(&"right", false, _ignore_transitions)
		if event.is_action_pressed("climb_up"):
			move(&"up", false, _ignore_transitions)
		if event.is_action_pressed("climb_down"):
			move(&"down", false, _ignore_transitions)
		if event.is_action_pressed("turn_left"):
			turn(COUNTERCLOCKWISE, _ignore_transitions)
		if event.is_action_pressed("turn_right"):
			turn(CLOCKWISE, _ignore_transitions)
		if event.is_action_pressed("interact"):
			_Interact()


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

func _Interact() -> void:
	if entity == null: return
	var options : Dictionary = {&"primary_type":&"Door"}
	var doors : Array = entity.get_local_entities(options)
	doors.append_array(entity.get_adjacent_entities(options))
	var adj_facing : CrawlGlobals.SURFACE = CrawlGlobals.Get_Adjacent_Surface(entity.facing)
	for door in doors:
		if door.position == entity.position and door.facing == entity.facing:
			door.interact(entity)
			return
		if door.position != entity.position and door.facing == adj_facing:
			door.interact(entity)

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
	set_process_unhandled_input(not enabled)
	set_process(not enabled)
	enable_schedule_movement_locking(not enabled)
	if enabled:
		if transition_started.is_connected(_on_transition_started):
			transition_started.disconnect(_on_transition_started)
		if transition_complete.is_connected(_on_transition_completed):
			transition_complete.disconnect(_on_transition_completed)
		if entity_changing.is_connected(_on_player_entity_changing):
			entity_changing.disconnect(_on_player_entity_changing)
		if entity_changed.is_connected(_on_player_entity_changed):
			entity_changed.disconnect(_on_player_entity_changed)
	else:
		if not transition_started.is_connected(_on_transition_started):
			transition_started.connect(_on_transition_started)
		if not transition_complete.is_connected(_on_transition_completed):
			transition_complete.connect(_on_transition_completed)
		if not entity_changing.is_connected(_on_player_entity_changing):
			entity_changing.connect(_on_player_entity_changing)
		if not entity_changed.is_connected(_on_player_entity_changed):
			entity_changed.connect(_on_player_entity_changed)
		if entity != null:
			_on_player_entity_changed()

func _on_player_entity_changing() -> void:
	if entity == null: return
	Scheduler.remove_registered_primary()

func _on_player_entity_changed() -> void:
	if entity == null: return
	Scheduler.register_primary_entity(entity)

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
	else:
		entity.schedule_end()


