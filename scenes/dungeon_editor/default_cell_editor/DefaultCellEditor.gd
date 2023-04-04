extends Control

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal resource_changed()


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFAULT_SURFACE_SETS_FILEPATH : String = "user://de_surface_sets.tres"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ceiling_resource : StringName = &"":		set = set_ceiling_resource
@export var ground_resource : StringName = &"":			set = set_ground_resource
@export var north_resource : StringName = &"":			set = set_north_resource
@export var south_resource : StringName = &"":			set = set_south_resource
@export var east_resource : StringName = &"":			set = set_east_resource
@export var west_resource : StringName = &"":			set = set_west_resource

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _surface_sets : CrawlCellSurfaceSets = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _create_set : Control = %CreateSet
@onready var _set_info : Control = %SetInfo
@onready var _line_edit_set_name : LineEdit = %LineEdit_SetName
@onready var _line_edit_create_desc : LineEdit = %LineEdit_CreateDesc
@onready var _set_selection : OptionButton = %SetSelection
@onready var _label_description : Label = %Label_Description
@onready var _set_options : MenuButton = %SetOptions


@onready var _ceiling_view : Control = %CeilingView
@onready var _ground_view : Control = %GroundView
@onready var _north_view : Control = %NorthView
@onready var _south_view : Control = %SouthView
@onready var _east_view : Control = %EastView
@onready var _west_view : Control = %WestView
@onready var _resource_options : PopupMenu = $ResourceOptions

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_ceiling_resource(r : StringName) -> void:
	if r != ceiling_resource:
		ceiling_resource = r
		_UpdateResourceViews()

func set_ground_resource(r : StringName) -> void:
	if r != ground_resource:
		ground_resource = r
		_UpdateResourceViews()

func set_north_resource(r : StringName) -> void:
	if r != north_resource:
		north_resource = r
		_UpdateResourceViews()

func set_south_resource(r : StringName) -> void:
	if r != south_resource:
		south_resource = r
		_UpdateResourceViews()

func set_east_resource(r : StringName) -> void:
	if r != east_resource:
		east_resource = r
		_UpdateResourceViews()

func set_west_resource(r : StringName) -> void:
	if r != west_resource:
		west_resource = r
		_UpdateResourceViews()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_set_selection.item_selected.connect(_on_set_selection_item_selected)
	var pop : PopupMenu = _set_options.get_popup()
	pop.id_pressed.connect(_on_set_options_id_pressed)
	
	_surface_sets = load(DEFAULT_SURFACE_SETS_FILEPATH)
	if _surface_sets == null:
		_surface_sets = CrawlCellSurfaceSets.new()
	_UpdateSetSelectionList()
	_set_selection.select(-1)
	
	_ceiling_view.pressed.connect(_on_surface_pressed.bind(&"ceiling", CrawlGlobals.SURFACE.Ceiling))
	_ground_view.pressed.connect(_on_surface_pressed.bind(&"ground", CrawlGlobals.SURFACE.Ground))
	_north_view.pressed.connect(_on_surface_pressed.bind(&"wall", CrawlGlobals.SURFACE.North))
	_south_view.pressed.connect(_on_surface_pressed.bind(&"wall", CrawlGlobals.SURFACE.South))
	_east_view.pressed.connect(_on_surface_pressed.bind(&"wall", CrawlGlobals.SURFACE.East))
	_west_view.pressed.connect(_on_surface_pressed.bind(&"wall", CrawlGlobals.SURFACE.West))
	
	_resource_options.index_pressed.connect(_on_resource_item_index_selected)
	if _surface_sets.has_surface_set(&"default"):
		_UpdateResourceFromSurfaceSet(&"default")
	_UpdateResourceViews()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateResourceViews() -> void:
	var set_res : Callable = func(view : Control, type : StringName, res : StringName):
		if type != &"" and res != &"" and not RLT.has_resource(type, res): return
		if view == null: return
		if not view.is_resource(type, res):
			view.set_resource(type, res)
			resource_changed.emit()
	
	set_res.call(_ceiling_view, &"ceiling", ceiling_resource)
	set_res.call(_ground_view, &"ground", ground_resource)
	
	set_res.call(_north_view, &"wall", north_resource)
	set_res.call(_south_view, &"wall", south_resource)
	set_res.call(_east_view, &"wall", east_resource)
	set_res.call(_west_view, &"wall", west_resource)

func _UpdateResourceFromSurfaceSet(set_name : String) -> void:
	if not _surface_sets.has_surface_set(set_name): return
	var info : Dictionary = _surface_sets.get_surface_set(set_name)
	if info.is_empty(): return
	
	ground_resource = info[&"ground"]
	ceiling_resource = info[&"ceiling"]
	north_resource = info[&"north"]
	south_resource = info[&"south"]
	east_resource = info[&"east"]
	west_resource = info[&"west"]
	
	_label_description.text = info[&"description"]
	_UpdateResourceViews()

func _UpdateSetSelectionList() -> void:
	if _set_selection == null: return
	_set_selection.clear()
	
	var set_list : Array = _surface_sets.get_set_list()
	for item in set_list:
		var idx : int = _set_selection.item_count
		_set_selection.add_item(item["set_name"])
		_set_selection.set_item_metadata(idx, item["set_name"])

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_surface_pressed(section_name : StringName, surface : CrawlGlobals.SURFACE) -> void:
	if not RLT.has_section(section_name): return
	_resource_options.clear()

	_resource_options.add_item("Empty")
	_resource_options.set_item_metadata(0, {
		&"section":section_name,
		&"resource_name":&"",
		&"surface":surface
	})

	for item in RLT.get_resource_list(section_name):
		var idx : int = _resource_options.item_count
		_resource_options.add_item(item[&"description"])
		_resource_options.set_item_metadata(idx, {
			&"section":section_name,
			&"resource_name":item[&"name"],
			&"surface":surface
		})
	_resource_options.popup_centered()

func _on_resource_item_index_selected(idx : int) -> void:
	var meta = _resource_options.get_item_metadata(idx)
	if meta == null: return
	if typeof(meta) != TYPE_DICTIONARY: return
	match meta[&"surface"]:
		CrawlGlobals.SURFACE.Ceiling:
			ceiling_resource = meta[&"resource_name"]
		CrawlGlobals.SURFACE.Ground:
			ground_resource = meta[&"resource_name"]
		CrawlGlobals.SURFACE.North:
			north_resource = meta[&"resource_name"]
		CrawlGlobals.SURFACE.South:
			south_resource = meta[&"resource_name"]
		CrawlGlobals.SURFACE.East:
			east_resource = meta[&"resource_name"]
		CrawlGlobals.SURFACE.West:
			west_resource = meta[&"resource_name"]

func _on_set_selection_item_selected(idx : int) -> void:
	if not (idx >= 0 and idx < _set_selection.item_count): return
	var set_name : String = _set_selection.get_item_metadata(idx)
	if set_name.is_empty(): return
	_UpdateResourceFromSurfaceSet(set_name)

func _on_set_options_id_pressed(id : int) -> void:
	match id:
		0: # Create new Surface Set
			_set_info.visible = false
			_create_set.visible = true
			_line_edit_set_name.grab_focus()
		1: # Remove currently selected Surface Set
			var sid : int = _set_selection.get_selected_id()
			if sid < 0: return
			var set_name : String = _set_selection.get_selected_metadata()
			_surface_sets.remove_surface_set(set_name)
			ResourceSaver.save(_surface_sets, DEFAULT_SURFACE_SETS_FILEPATH)

func _on_store_set_pressed():
	if _line_edit_set_name.text.is_empty(): return
	var set_def : Dictionary = {
		&"ground":ground_resource,
		&"ceiling":ceiling_resource,
		&"north":north_resource,
		&"south":south_resource,
		&"east":east_resource,
		&"west":west_resource,
	}
	if not _line_edit_create_desc.text.is_empty():
		set_def[&"description"] = _line_edit_create_desc.text
	
	if _surface_sets.has_surface_set(_line_edit_set_name.text):
		_surface_sets.update_surface_set(_line_edit_set_name.text, set_def)
	else:
		_surface_sets.add_surface_set(_line_edit_set_name.text, set_def)
	
	ResourceSaver.save(_surface_sets, DEFAULT_SURFACE_SETS_FILEPATH)
	_on_cancel_set_pressed()


func _on_cancel_set_pressed():
	_create_set.visible = false
	_line_edit_create_desc.text = ""
	_line_edit_set_name.text = ""
	_set_info.visible = true
