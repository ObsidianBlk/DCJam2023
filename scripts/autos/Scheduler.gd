extends Node


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal primary_entity_active()

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _primary : WeakRef = weakref(null)
var _mobs : Dictionary = {}

var _primary_active : bool = true

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CleanEntityList() -> void:
	for uuid in _mobs:
		if _mobs[uuid][&"entity"].get_ref() == null:
			_mobs.erase(uuid)

func _GetPriorityHashedEntityDict() -> Dictionary:
	var eh : Dictionary = {}
	for uuid in _mobs:
		if _mobs[uuid][&"entity"].get_ref() == null: continue
		if not _mobs[uuid][&"priority"] in eh:
			eh[_mobs[uuid][&"priority"]] = []
		eh[_mobs[uuid][&"priority"]].append(uuid)
		_mobs[uuid][&"processed"] = false
	return eh

func _AllProcessed() -> bool:
	for uuid in _mobs:
		if _mobs[uuid][&"entity"].get_ref() == null: continue
		if not _mobs[uuid][&"processed"]: return false
	return true


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func register_primary_entity(prime : CrawlEntity) -> void:
	if _primary.get_ref() != null:
		if _primary.get_ref().uuid == prime.uuid: return
		remove_registered_primary()
	
	if is_entity_registered(prime):
		remove_registered_entity(prime)
	_primary = weakref(prime)
	
	if prime != null:
		if not prime.schedule_ended.is_connected(_on_primary_schedule_ended):
			prime.schedule_ended.connect(_on_primary_schedule_ended)
		if not prime.schedule_started.is_connected(_on_prime_schedule_started):
			prime.schedule_started.connect(_on_prime_schedule_started)
		prime.schedule_start() # Make sure the primary begins in the start state.

func is_entity_registered_as_primary(entity : CrawlEntity) -> bool:
	if entity == null: return false
	if _primary.get_ref() == null: return false
	return _primary.get_ref().uuid == entity.uuid

func remove_registered_primary() -> void:
	if _primary.get_ref() == null: return
	if _primary.get_ref().schedule_ended.is_connected(_on_primary_schedule_ended):
		_primary.get_ref().schedule_ended.disconnect(_on_primary_schedule_ended)
	_primary = weakref(null)

func register_entity(entity : CrawlEntity, priority : int = 0) -> void:
	priority = max(0, priority)
	if entity.uuid in _mobs:
		_mobs[entity.uuid][&"priority"] = priority
		return
	
	_mobs[entity.uuid] = {
		&"entity":weakref(entity),
		&"processed":false,
		&"priority":priority
	}
	if not entity.schedule_ended.is_connected(_on_entity_schedule_ended.bind(entity)):
		entity.schedule_ended.connect(_on_entity_schedule_ended.bind(entity))
	entity.schedule_end() # Make sure the entity thinks it's in the end state.
	

func is_entity_registered(entity : CrawlEntity) -> bool:
	if entity == null: return false
	return entity.uuid in _mobs

func remove_registered_entity(entity : CrawlEntity) -> void:
	if entity == null: return
	if not entity.uuid in _mobs: return
	
	if entity.schedule_ended.is_connected(_on_entity_schedule_ended.bind(entity)):
		entity.schedule_ended.disconnect(_on_entity_schedule_ended.bind(entity))
	_mobs.erase(entity.uuid)

func is_prime_active() -> bool:
	return _primary_active

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_prime_schedule_started(data : Dictionary) -> void:
	_primary_active = true
	primary_entity_active.emit()

func _on_primary_schedule_ended(data : Dictionary) -> void:
	_primary_active = false
	_CleanEntityList()
	var eh : Dictionary = _GetPriorityHashedEntityDict()
	if eh.is_empty():
		if _primary.get_ref() != null:
			# Allow the primary entity to finish up any of it's emits.
			_primary.get_ref().schedule_start.call_deferred()
	else:
		var priorities = eh.keys()
		priorities.sort_custom(func(a : int, b : int): return a > b)
		for priority in priorities:
			for uuid in eh[priority]:
				if _mobs[uuid][&"entity"].get_ref() == null: continue
				_mobs[uuid][&"entity"].get_ref().schedule_start()

func _on_entity_schedule_ended(data : Dictionary, entity : CrawlEntity) -> void:
	if _primary_active: return
	if entity.uuid in _mobs:
		_mobs[entity.uuid][&"processed"] = true
	if _AllProcessed() and _primary.get_ref() != null:
		# Allow the primary entity to finish up any of it's emits.
		_primary.get_ref().schedule_start.call_deferred()

