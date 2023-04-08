extends DCJMob

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const BASE_GROWTH_RATE : float = 1.0
const ADULT_GROWTH_VALUE : float = 40.0
const MAX_GROWTH_VALUE : float = 100.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _growth : float = 0.0
var _dead : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprout : Sprite3D = $Sprout
@onready var _sfx : Node3D = $SFX

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	initialize_mob()
	#_growth = randf_range(0.0, MAX_GROWTH_VALUE)
	_growth = MAX_GROWTH_VALUE
	CrawlGlobals.editor_mode_changed.connect(_on_Sprout_editor_mode_changed)
	_on_Sprout_editor_mode_changed(CrawlGlobals.In_Editor_Mode())

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ProcessAI() -> void:
	if entity == null: return
	if _dead:
		entity.schedule_end()
		return
	
	# First... grow self...
	if _growth < MAX_GROWTH_VALUE:
		var mult : float = 1.0 + float(_CountNeighborPlants())
		_growth = min(MAX_GROWTH_VALUE, _growth + (BASE_GROWTH_RATE * mult))
	
	if _growth >= ADULT_GROWTH_VALUE:
		for surface in [CrawlGlobals.SURFACE.North, CrawlGlobals.SURFACE.East, CrawlGlobals.SURFACE.South, CrawlGlobals.SURFACE.West]:
			entity.facing = surface
			if not entity.can_move(&"foreward", true): continue
			var player : Array = entity.get_entities_in_direction(surface, {"primary_type":&"Player"})
			if player.size() > 0:
				_growth -= ADULT_GROWTH_VALUE
				await _AttackAsync(surface, player[0])
				break
	
	entity.schedule_end()

func _CountNeighborPlants() -> int:
	var count : int = 0
	for surface in [CrawlGlobals.SURFACE.North, CrawlGlobals.SURFACE.East, CrawlGlobals.SURFACE.South, CrawlGlobals.SURFACE.West]:
		var sprouts : Array = entity.get_entities_in_direction(surface, {"sub_type":&"Sprout"})
		if sprouts.size() > 0:
			count += 1
	return count

func _AttackAsync(surface : CrawlGlobals.SURFACE, player : CrawlEntity) -> void:
	var dir : Vector3 = CrawlGlobals.Get_Direction_From_Surface(surface)
	var tween : Tween = create_tween()
	tween.tween_property(_sprout, "position", _sprout.position + (dir * 2.5), 0.25)
	await tween.finished
	if entity != null:
		player.attack(10.0, CrawlGlobals.ATTACK_TYPE.Physical)
	tween = create_tween()
	tween.tween_property(_sprout, "position", Vector3.ZERO, 0.5)
	await tween.finished

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_growth() -> float:
	return _growth

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_Sprout_editor_mode_changed(enabled : bool) -> void:
	if entity == null: return
	if enabled:
		if CrawlTriggerRelay.request.is_connected(_on_request):
			CrawlTriggerRelay.request.disconnect(_on_request)
		if entity.attacked.is_connected(_on_sprout_attacked):
			entity.attacked.disconnect(_on_sprout_attacked)
	else:
		if not CrawlTriggerRelay.request.is_connected(_on_request):
			CrawlTriggerRelay.request.connect(_on_request)
		if not entity.attacked.is_connected(_on_sprout_attacked):
			entity.attacked.connect(_on_sprout_attacked)

func _on_request(req : Dictionary) -> void:
	if not "request" in req: return
	match req["request"]:
		&"fertilize":
			if not "amount" in req: return
			if typeof(req["amount"]) != TYPE_FLOAT: return
			if req["amount"] > 0:
				_growth += req["amount"]

func _on_sprout_attacked(dmg : float, type : CrawlGlobals.ATTACK_TYPE) -> void:
	if _dead: return
	_dead = true
	_sfx.finished.connect(free_mob, CONNECT_ONE_SHOT)
	_sfx.play_group("chop")
	
