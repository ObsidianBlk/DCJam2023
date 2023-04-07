extends DCJMob


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MAX_HP : float = 30.0

const BASE_GROWTH_RATE : float = 1.15
const ADULT_GROWTH_VALUE : float = 50.0
const MAX_GROWTH_VALUE : float = 150.0

const ATTACK_COST : float = 40.1

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _growth : float = 0.0
var _hp : float = MAX_HP

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	initialize_mob(100)
	_growth = randf_range(ADULT_GROWTH_VALUE * 0.5, MAX_GROWTH_VALUE)
	CrawlGlobals.editor_mode_changed.connect(_on_POD_editor_mode_changed)
	_on_POD_editor_mode_changed(CrawlGlobals.In_Editor_Mode())

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ProcessAI() -> void:
	if entity == null: return
	if _growth < MAX_GROWTH_VALUE:
		var mult : float = 1.0 + float(_CountNeighborPlants())
		_growth = min(MAX_GROWTH_VALUE, _growth + (BASE_GROWTH_RATE * mult))
	
	var map : CrawlMap = entity.get_map()
	if _growth >= ADULT_GROWTH_VALUE and map != null:
		for surface in [CrawlGlobals.SURFACE.North, CrawlGlobals.SURFACE.East, CrawlGlobals.SURFACE.South, CrawlGlobals.SURFACE.West]:
			if not _FindPlayerEntity(surface): continue
			var attent : CrawlEntity = CrawlEntity.new()
			attent.uuid = UUID.v7()
			attent.type = &"Mob:PODAttack"
			attent.position = entity.position + CrawlGlobals.Get_Direction_From_Surface(surface)
			attent.facing = surface
			map.add_entity(attent)
			_growth -= ATTACK_COST
			break
	entity.schedule_end()

func _CountNeighborPlants() -> int:
	var count : int = 0
	for surface in [CrawlGlobals.SURFACE.North, CrawlGlobals.SURFACE.East, CrawlGlobals.SURFACE.South, CrawlGlobals.SURFACE.West]:
		var sprouts : Array = entity.get_entities_in_direction(surface, {"sub_type":&"PODPlant"})
		if sprouts.size() > 0:
			count += 1
	return count

func _FindPlayerEntity(surface : CrawlGlobals.SURFACE) -> bool:
	for i in range(2):
		var neighbor : Vector3i = entity.position + (CrawlGlobals.Get_Direction_From_Surface(surface) * (i + 1))
		var player : Array = entity.get_entities({"position":neighbor, "type":&"Player"})
		if player.size() > 0:
			return true
	return false

func _SpawnFruit() -> void:
	if entity == null: return
	var map : CrawlMap = entity.get_map()
	if map == null: return
	
	var fent : CrawlEntity = CrawlEntity.new()
	fent.uuid = UUID.v7()
	fent.type = &"Item:Fruit"
	fent.position = entity.position
	
	map.add_entity(fent)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_POD_editor_mode_changed(enabled : bool) -> void:
	if entity == null: return
	if enabled:
		if entity.attacked.is_connected(_on_pod_attacked):
			entity.attacked.disconnect(_on_pod_attacked)
	else:
		if not entity.attacked.is_connected(_on_pod_attacked):
			entity.attacked.connect(_on_pod_attacked)

func _on_pod_attacked(dmg : float, type : CrawlGlobals.ATTACK_TYPE) -> void:
	_hp -= dmg
	if _hp <= 0.0:
		_SpawnFruit()
		free_mob.call_deferred()
