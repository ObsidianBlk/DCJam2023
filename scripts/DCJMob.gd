extends CrawlEntityNode3D
class_name DCJMob

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _scheduler_priority : int = 0

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ProcessAI() -> void: # Intended to be overridden!
	entity.schedule_end()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func initialize_mob(priority : int = -1) -> void:
	if priority >= 0:
		_scheduler_priority = priority
	if not is_mob_inialized():
		CrawlGlobals.editor_mode_changed.connect(_on_DCJMob_editor_mode_changed)
		_on_DCJMob_editor_mode_changed(CrawlGlobals.In_Editor_Mode())

func is_mob_inialized() -> bool:
	return CrawlGlobals.editor_mode_changed.is_connected(_on_DCJMob_editor_mode_changed)

func free_mob() -> void:
	if entity == null:
		queue_free()
	else:
		var map : CrawlMap = entity.get_map()
		if map == null:
			queue_free()
		else:
			map.remove_entity(entity)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_DCJMob_editor_mode_changed(enabled : bool) -> void:
	use_entity_direct_update(enabled)
	enable_schedule_movement_locking(not enabled)
	if enabled:
		if entity_changing.is_connected(_on_DCJMob_entity_changing):
			entity_changing.disconnect(_on_DCJMob_entity_changing)
		if entity_changed.is_connected(_on_DCJMob_entity_changed):
			entity_changed.disconnect(_on_DCJMob_entity_changed)
	else:
		if not entity_changing.is_connected(_on_DCJMob_entity_changing):
			entity_changing.connect(_on_DCJMob_entity_changing)
		if not entity_changed.is_connected(_on_DCJMob_entity_changed):
			entity_changed.connect(_on_DCJMob_entity_changed)
		if entity != null:
			_on_DCJMob_entity_changed()

func _on_DCJMob_entity_changing() -> void:
	if entity == null: return
	Scheduler.remove_registered_entity(entity)
	if entity.schedule_started.is_connected(_on_schedule_started):
		entity.schedule_started.disconnect(_on_schedule_started)

func _on_DCJMob_entity_changed() -> void:
	if entity == null: return
	if not entity.schedule_started.is_connected(_on_schedule_started):
		entity.schedule_started.connect(_on_schedule_started)
	Scheduler.register_entity(entity, _scheduler_priority)

func _on_schedule_started(data : Dictionary) -> void:
	_ProcessAI()
