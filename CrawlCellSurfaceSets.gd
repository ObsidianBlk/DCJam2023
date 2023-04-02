extends Resource
class_name CrawlCellSurfaceSets


# --------------------------------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------------------------------
const SURFACE_SET_SCHEMA = {
	&"description":{&"req":false, &"type":TYPE_STRING},
	&"ground":{&"req":true, &"type":TYPE_STRING_NAME, &"allow_empty":true},
	&"ceiling":{&"req":true, &"type":TYPE_STRING_NAME, &"allow_empty":true},
	&"north":{&"req":true, &"type":TYPE_STRING_NAME, &"allow_empty":true},
	&"east":{&"req":true, &"type":TYPE_STRING_NAME, &"allow_empty":true},
	&"south":{&"req":true, &"type":TYPE_STRING_NAME, &"allow_empty":true},
	&"west":{&"req":true, &"type":TYPE_STRING_NAME, &"allow_empty":true},
}

const SURFACE_SETS_SCHEMA ={
	&"!KEY_OF_TYPE_str":{&"type":TYPE_STRING, &"def":{
		&"type":TYPE_DICTIONARY, &"def":SURFACE_SET_SCHEMA
	}}
}

# --------------------------------------------------------------------------------------------------
# "Export" Variables
# --------------------------------------------------------------------------------------------------
var _surf_sets : Dictionary = {}


# --------------------------------------------------------------------------------------------------
# Override Methods
# --------------------------------------------------------------------------------------------------
func _get(property : StringName) -> Variant:
	match property:
		&"surface_sets":
			return _surf_sets
	return null

func _set(property : StringName, value : Variant) -> bool:
	var success : bool = false
	match property:
		&"surface_sets":
			if typeof(value) == TYPE_DICTIONARY:
				if DSV.verify(value, SURFACE_SETS_SCHEMA) == OK:
					_surf_sets = value
					success = true
	return success

func _get_property_list() -> Array:
	return [
		{
			name = "Crawl Cell Surface Sets",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY
		},
		{
			name = "surface_sets",
			type = TYPE_DICTIONARY,
			usage = PROPERTY_USAGE_STORAGE
		}
	]

# --------------------------------------------------------------------------------------------------
# Private Methods
# --------------------------------------------------------------------------------------------------
func _SurfaceToName(surface : CrawlGlobals.SURFACE) -> StringName:
	match surface:
		CrawlGlobals.SURFACE.Ground:
			&"ground"
		CrawlGlobals.SURFACE.Ceiling:
			&"ceiling"
		CrawlGlobals.SURFACE.North:
			&"north"
		CrawlGlobals.SURFACE.South:
			&"south"
		CrawlGlobals.SURFACE.East:
			&"east"
		CrawlGlobals.SURFACE.West:
			&"west"
	return &""
# --------------------------------------------------------------------------------------------------
# Public Methods
# --------------------------------------------------------------------------------------------------
func get_set_list() -> Array:
	var entries : Array = []
	for set_name in _surf_sets.keys():
		entries.append({
			&"set_name":set_name,
			&"description":"" if not &"description" in _surf_sets[set_name] else _surf_sets[set_name][&"description"]
		})
	return entries

func get_surface_set(set_name : String) -> Dictionary:
	if not set_name in _surf_sets: return {}
	return {
		&"ground":_surf_sets[set_name][&"ground"],
		&"ceiling":_surf_sets[set_name][&"ceiling"],
		&"north":_surf_sets[set_name][&"north"],
		&"south":_surf_sets[set_name][&"south"],
		&"east":_surf_sets[set_name][&"east"],
		&"west":_surf_sets[set_name][&"west"],
		&"description":"" if not &"description" in _surf_sets[set_name] else _surf_sets[set_name][&"description"]
	}

func has_surface_set(set_name : String) -> bool:
	return set_name in _surf_sets

func add_surface_set(set_name : String, set_def : Dictionary = {}) -> void:
	if set_name in _surf_sets: return
	_surf_sets[set_name] = {
		&"ground":&"",
		&"ceiling":&"",
		&"north":&"",
		&"south":&"",
		&"east":&"",
		&"west":&"",
	}
	if not set_def.is_empty():
		update_surface_set(set_name, set_def)

func remove_surface_set(set_name : String) -> void:
	if not set_name in _surf_sets: return
	_surf_sets.erase(set_name)

func update_surface_set(set_name : String, set_def : Dictionary) -> void:
	if not set_name in _surf_sets: return
	if DSV.verify(set_def, SURFACE_SET_SCHEMA) != OK: return
	_surf_sets[set_name][&"ground"] = set_def[&"ground"]
	_surf_sets[set_name][&"ceiling"] = set_def[&"ceiling"]
	_surf_sets[set_name][&"north"] = set_def[&"north"]
	_surf_sets[set_name][&"south"] = set_def[&"south"]
	_surf_sets[set_name][&"east"] = set_def[&"east"]
	_surf_sets[set_name][&"west"] = set_def[&"west"]

	if &"description" in set_def:
		_surf_sets[set_name][&"description"] = set_def[&"description"]
	elif &"description" in _surf_sets[set_name]:
		_surf_sets[set_name].erase(&"description")

func set_surface_resource(set_name : String, surface : CrawlGlobals.SURFACE, resource : StringName) -> void:
	if not set_name in _surf_sets: return
	_surf_sets[set_name][_SurfaceToName(surface)] = resource

func set_description(set_name : String, description : String) -> void:
	if not set_name in _surf_sets: return
	if description.is_empty():
		if &"description" in _surf_sets[set_name]:
			_surf_sets[set_name].erase(&"description")
	else:
		_surf_sets[set_name][&"description"] = description

