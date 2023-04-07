extends CrawlEntityNode3D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_KEY_ATTACK_DIR : String = "attack_dir"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _steps : int = 1

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _anim : AnimationPlayer = $Anim
@onready var _body : Node3D = $Body

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	entity_changed.connect(_on_entity_changed)
	_anim.animation_finished.connect(_on_anim_finished)
	if entity != null:
		_on_entity_changed()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateBodyFacing() -> void:
	if entity == null or _body == null: return
	match entity.facing:
		CrawlGlobals.SURFACE.North:
			_body.rotation_degrees.y = 180.0
		CrawlGlobals.SURFACE.East:
			_body.rotation_degrees.y = 270.0
		CrawlGlobals.SURFACE.South:
			_body.rotation_degrees.y = 0.0
		CrawlGlobals.SURFACE.West:
			_body.rotation_degrees.y = 90.0

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func free_me() -> void:
	if entity == null:
		queue_free()
	else:
		var map : CrawlMap = entity.get_map()
		if map == null:
			queue_free()
		else:
			map.remove_entity(entity)

func check_player_attack() -> void:
	if entity == null: return
	var player : Array = entity.get_local_entities({"primary_type":&"Player"})
	if player.size() > 0:
		player[0].attack(10.0, CrawlGlobals.ATTACK_TYPE.Physical)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_anim_finished(anim_name : StringName) -> void:
	if _steps == 0:
		free_me.call_deferred()
	else:
		_steps -= 1
		entity.move(&"foreward", true)
		_anim.play("attack")

func _on_entity_changed() -> void:
	if entity == null: return
	entity.set_block_all(false)
	use_entity_direct_update(true)
	_UpdateBodyFacing()
	if not CrawlGlobals.In_Editor_Mode():
		print("Starting attack run!")
		_anim.play("attack")
