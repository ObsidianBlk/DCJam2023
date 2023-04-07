extends CrawlEntityNode3D


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	entity_changed.connect(_on_entity_changed)
	if entity != null:
		_on_entity_changed()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_entity_changed() -> void:
	if entity == null: return
	entity.set_block_all(false)
	use_entity_direct_update(true)
