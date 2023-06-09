# (R)esource (L)ookup (T)able
extends Node


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ENV_LOOKUP : Dictionary = {
	&"default":{
		&"src":"res://objects/world_environments/default.tres",
		&"description":"Default dungeon world environment."
	},
}

const ENTITIES_LOOKUP : Dictionary = {
	&"Unique":{
		&"Player":{&"name":&"Player Start"},
		&"Viewer":{&"name":&"Viewer Start"},
	},
	&"Mob":{
		&"Sprout":{&"name":&"Sprout Plant"},
		&"PODPlant":{&"name":&"POD Plant"}
	},
	&"Item":{
		&"Survivor":{
			&"name":&"Survivor",
			&"ui":"res://objects/entity_objects/survivor/DE_survivor_editor/DE_SurvivorEditor.tscn"
		},
		&"Fruit":{
			&"name":&"POD Plant Fruit"
		},
	},
	&"Door":{
		&"Basic_Interactable":{&"name":&"Basic Door"},
		&"Terminal":{&"name":&"Escape Terminal"}
	},
	&"Ramp":{
		&"Exterior_A":{&"name":&"Planet Exterior Ramp A"}
	},
	&"Trigger":{
		&"Light":{
			&"name":&"Triggerable Light",
			&"ui":"res://objects/entity_objects/trigger_light/DE_trigger_light_editor/DE_TriggerLightEditor.tscn"
		},
		&"Gate_AND":{
			&"name":&"AND Gate",
			&"ui":"res://objects/entity_objects/crawl_AND_gate_3d/DE_AND_gate_editor/DE_ANDGateEditor.tscn"
		},
		&"Gate_OR":{
			&"name":&"OR Gate",
			&"ui":"res://objects/entity_objects/crawl_OR_gate_3d/DE_OR_gate_editor/DE_ORGateEditor.tscn"
		},
		&"Gate_NOT":{
			&"name":&"NOT Gate",
			&"ui":"res://objects/entity_objects/crawl_NOT_gate_3d/DE_NOT_gate_editor/DE_NOTGateEditor.tscn"
		},
		&"Gate_NAND":{
			&"name":&"NAND Gate",
			&"ui":"res://objects/entity_objects/crawl_NAND_gate_3d/DE_NAND_gate_editor/DE_NANDGateEditor.tscn"
		},
		&"Gate_NOR":{
			&"name":&"NOR Gate",
			&"ui":"res://objects/entity_objects/crawl_NOR_gate_3d/DE_NOR_gate_editor/DE_NORGateEditor.tscn"
		},
		&"Gate_XOR":{
			&"name":&"XOR Gate",
			&"ui":"res://objects/entity_objects/crawl_XOR_gate_3d/DE_XOR_gate_editor/DE_XORGateEditor.tscn"
		},
		&"Logic_Memory":{
			&"name":&"Logical Memory",
			&"ui":"res://objects/entity_objects/crawl_memory_logic_3d/DE_memory_logic_editor/DE_MemoryLogicEditor.tscn"
		},
		&"Logic_Timer":{
			&"name":&"Logical Timer",
			&"ui":"res://objects/entity_objects/crawl_timer_logic_3d/DE_timer_logic_editor/DE_TimerLogicEditor.tscn"
		},
		&"Exit":{
			&"name":&"Dungeon Exit",
			&"ui":"res://objects/entity_objects/trigger_exit/DE_trigger_exit_editor/DE_TriggerExitEditor.tscn"
		},
		&"Relay":{
			&"name":&"Trigger Relay",
			&"ui":"res://objects/entity_objects/trigger_relay/DE_trigger_relay_editor/DE_TriggerRelayEditor.tscn"
		}
	},
}

const LOOKUP : Dictionary = {
	&"ground":{
		&"tileA":{
			&"src":"res://objects/cell_resources/floors/Floor_TileA.tscn",
			&"description":"Ground Tile A"
		},
		&"tileB":{
			&"src":"res://objects/cell_resources/floors/Floor_TileB.tscn",
			&"description":"Ground Tile B"
		},
		&"basic":{
			&"src":"res://objects/cell_resources/floors/Floor_Basic.tscn",
			&"description":"Basic ground floor"
		},
		&"floor_pod":{
			&"src":"res://objects/cell_resources/POD/floors/Floor_POD.tscn",
			&"description":"Escape Pod Floor"
		},
		&"planet_ground":{
			&"src":"res://objects/cell_resources/Planet_Exterior/floors/ground.tscn",
			&"description":"Planet Exterior Sandy Ground"
		},
	},
	&"ceiling":{
		&"tileA":{
			&"src":"res://objects/cell_resources/ceilings/Ceiling_TileA.tscn",
			&"description":"Ceiling Tile A"
		},
		&"tileB":{
			&"src":"res://objects/cell_resources/ceilings/Ceiling_TileB.tscn",
			&"description":"Ceiling Tile B"
		},
		&"basic":{
			&"src":"res://objects/cell_resources/ceilings/Ceiling_Basic.tscn",
			&"description":"Basic ceiling"
		},
		&"ceiling_pod":{
			&"src":"res://objects/cell_resources/POD/ceilings/Ceiling_POD.tscn",
			&"description":"Escape Pod Ceiling"
		},
	},
	&"wall":{
		&"tileA":{
			&"src":"res://objects/cell_resources/walls/Wall_TileA.tscn",
			&"description":"Wall Tile A"
		},
		&"tileB":{
			&"src":"res://objects/cell_resources/walls/Wall_TileB.tscn",
			&"description":"Wall Tile B"
		},
		&"basic":{
			&"src":"res://objects/cell_resources/walls/Wall_Basic.tscn",
			&"description":"Basic wall"
		},
		&"wall_pod_a":{
			&"src":"res://objects/cell_resources/POD/walls/Wall_PodA.tscn",
			&"description":"Escape Pod Wall"
		},
		&"wall_pod_b":{
			&"src":"res://objects/cell_resources/POD/walls/Wall_PodB.tscn",
			&"description":"Escape Pod Wall with Air Ducts"
		},
		&"wall_pod_c":{
			&"src":"res://objects/cell_resources/POD/walls/Wall_PodC.tscn",
			&"description":"Escape Pod Wall with Screen"
		},
		&"wall_planet_cliff_a":{
			&"src":"res://objects/cell_resources/Planet_Exterior/walls/Cliff_A.tscn",
			&"description":"Planet Exterior Cliff A"
		},
		&"wall_planet_cliff_b":{
			&"src":"res://objects/cell_resources/Planet_Exterior/walls/Cliff_B.tscn",
			&"description":"Planet Exterior Cliff B"
		},
	},
	
	&"entity":{
		&"Editor":{
			&"src":"res://objects/editor/Editor.tscn",
			&"description":"Editor entity"
		},
		&"Player":{
			&"src":"res://objects/player/Player.tscn",
			&"description":"Player start"
		},
		&"Viewer":{
			&"src":"res://objects/viewer/Viewer.tscn",
			&"description":"Viewer Start (for menu dungeons)"
		},
		&"Door:Basic_Interactable":{
			&"src":"res://objects/entity_objects/door_basic_interactable/DoorBasicInteractable.tscn",
			&"description":"Basic Interactable Door"
		},
		&"Door:Terminal":{
			&"src":"res://objects/entity_objects/terminal/Terminal.tscn",
			&"description":"Escape Terminal"
		},
		&"Ramp:Exterior_A":{
			&"src":"res://objects/entity_objects/exterior_ramp_a/ExteriorRampA.tscn",
			&"description":"Planet Exterior Ramp A"
		},
		&"Item:Survivor":{
			&"src":"res://objects/entity_objects/survivor/Survivor.tscn",
			&"description":"Survivor"
		},
		&"Item:Fruit":{
			&"src":"res://objects/entity_objects/fruit/Fruit.tscn",
			&"description":"POD Plant Fruit"
		},
		&"Mob:Sprout":{
			&"src":"res://objects/entity_objects/sprout/Sprout.tscn",
			&"description":"Sprout Plant"
		},
		&"Mob:PODPlant":{
			&"src":"res://objects/entity_objects/pod_plant/POD_Plant.tscn",
			&"description":"POD Plant"
		},
		&"Mob:PODAttack":{
			&"src":"res://objects/entity_objects/pod_attack/POD_Attack.tscn",
			&"description":"POD Plant Attack Root"
		},
		&"Trigger:Gate_AND":{
			&"src":"res://objects/entity_objects/crawl_AND_gate_3d/CrawlANDGate3D.tscn",
			&"description":"AND Gate"
		},
		&"Trigger:Gate_OR":{
			&"src":"res://objects/entity_objects/crawl_OR_gate_3d/CrawlORGate3D.tscn",
			&"description":"OR Gate"
		},
		&"Trigger:Gate_NOT":{
			&"src":"res://objects/entity_objects/crawl_NOT_gate_3d/CrawlNOTGate3D.tscn",
			&"description":"NOT Gate"
		},
		&"Trigger:Gate_NAND":{
			&"src":"res://objects/entity_objects/crawl_NAND_gate_3d/CrawlNANDGate3D.tscn",
			&"description":"NAND Gate"
		},
		&"Trigger:Gate_NOR":{
			&"src":"res://objects/entity_objects/crawl_NOR_gate_3d/CrawlNORGate3D.tscn",
			&"description":"NOR Gate"
		},
		&"Trigger:Gate_XOR":{
			&"src":"res://objects/entity_objects/crawl_XOR_gate_3d/CrawlXORGate3D.tscn",
			&"description":"XOR Gate"
		},
		&"Trigger:Logic_Memory":{
			&"src":"res://objects/entity_objects/crawl_memory_logic_3d/CrawlMemoryLogic3D.tscn",
			&"description":"Logical Memory"
		},
		&"Trigger:Logic_Timer":{
			&"src":"res://objects/entity_objects/crawl_timer_logic_3d/CrawlTimerLogic3D.tscn",
			&"description":"Logic Timer"
		},
		&"Trigger:Light":{
			&"src":"res://objects/entity_objects/trigger_light/TriggerLight.tscn",
			&"description":"Triggerable Light"
		},
		&"Trigger:Exit":{
			&"src":"res://objects/entity_objects/trigger_exit/TriggerExit.tscn",
			&"description":"Dungeon Exit"
		},
		&"Trigger:Relay":{
			&"src":"res://objects/entity_objects/trigger_relay/TriggerRelay.tscn",
			&"description":"Trigger Relay"
		}
	}
}

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_section_list() -> Array:
	return LOOKUP.keys()

func has_section(section : StringName) -> bool:
	return section in LOOKUP

func has_resource(section : StringName, resource_name : StringName) -> bool:
	if not section in LOOKUP: return false
	if not resource_name in LOOKUP[section]: return false
	return true

func get_resource_list(section : StringName) -> Array:
	if not section in LOOKUP: return []
	var list : Array = []
	for key in LOOKUP[section].keys():
		var item : Dictionary = {&"name":key, &"description":key}
		if &"description" in LOOKUP[section][key]:
			item[&"description"] = LOOKUP[section][key][&"description"]
		list.append(item)
	return list

func has_environment(environment_name : StringName) -> bool:
	return environment_name in ENV_LOOKUP

func get_environment_list() -> Array:
	var list : Array = []
	for key in ENV_LOOKUP.keys():
		var item : Dictionary = {&"name":key, &"description":key}
		if &"description" in ENV_LOOKUP[key]:
			item[&"description"] = ENV_LOOKUP[key][&"description"]
		list.append(item)
	return list

func get_entity_groups() -> Array:
	return ENTITIES_LOOKUP.keys()

func get_entity_info_in_group(group : StringName) -> Array:
	if not group in ENTITIES_LOOKUP: return []
	var tlist : Array = []
	for key in ENTITIES_LOOKUP[group].keys():
		var type : StringName = &""
		type = key if group == &"Unique" else StringName("%s:%s"%[group, key])
		tlist.append({
			&"type": type,
			&"name": ENTITIES_LOOKUP[group][key]["name"],
			&"ui": &"" if not "ui" in ENTITIES_LOOKUP[group] else ENTITIES_LOOKUP[group]["ui"]
		})
	return tlist

func get_entity_ui_from_type(entity_type : StringName) -> String:
	if entity_type == &"": return &""
	var parts : PackedStringArray = entity_type.split(":")
	var psize : int = parts.size()
	if not (psize >= 1 and psize <= 2): return &""
	var base : StringName = parts[0]
	var sub : StringName = &""
	if parts.size() == 1:
		base = &"Unique"
		sub = parts[0]
	else:
		sub = parts[1]
	
	if not base in ENTITIES_LOOKUP: return &""
	if not sub in ENTITIES_LOOKUP[base]: return &""
	
	return &"" if not "ui" in ENTITIES_LOOKUP[base][sub] else ENTITIES_LOOKUP[base][sub]["ui"]


func instantiate_resource(section : StringName, resource_name : StringName) -> Node3D:
	if not section in LOOKUP: return null
	if not resource_name in LOOKUP[section]: return null
	var scene : PackedScene = load(LOOKUP[section][resource_name][&"src"])
	if scene == null: return null
	return scene.instantiate()

func instantiate_environment(environment_name : StringName) -> Environment:
	if not environment_name in ENV_LOOKUP: return null
	var env = ResourceLoader.load(ENV_LOOKUP[environment_name][&"src"])
	if not is_instance_of(env, Environment): return null
	return env

func instantiate_entity_ui(entity_type : StringName) -> Control:
	var ui_src : String = get_entity_ui_from_type(entity_type)
	if ui_src.is_empty(): return null
	var CTRL : PackedScene = load(ui_src)
	if CTRL == null: return null
	return CTRL.instantiate()


