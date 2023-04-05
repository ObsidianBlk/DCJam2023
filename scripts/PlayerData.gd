extends Resource
class_name PlayerData


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal fruits_changed(amount)
signal oxy_changed(oxy, maxoxy)
signal blob_added(idx)
signal blob_hp_changed(idx, hp, maxhp)
signal blob_dead(idx)
signal dead()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const INIT_HP : float = 100.0
const INIT_OXYGEN : float = 100.0

const BLOB_OXY_INDEX : int = 1
const BLOB_DEFENSE_INDEX : int = 2

const BREATH_OXY_USAGE : float = 1.5
const BLOB_OXY_MULTIPLIER : float = 0.25
const FRUIT_OXY_AMOUNT : float = 30.0
const SUFFICATION_DAMAGE : float = 24.0

const BLOB_DEFENSE_MULTIPLIER : float = 0.5


# ------------------------------------------------------------------------------
# "Export" Variables
# ------------------------------------------------------------------------------
var _data : Dictionary = {
	"hp":[INIT_HP, -1, -1, -1],
	"oxy":INIT_OXYGEN,
	"fruits":0,
	"scrap":0,
}


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _RandomActiveBlobIndex() -> int:
	var available : Array = []
	for i in range(_data["hp"].size()):
		if _data["hp"][i] > 0:
			available.append(i)
	if available.size() <= 0: return -1
	var idx : int = randi_range(0, available.size())
	return available[idx]

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func blob_count() -> int:
	var count = 0
	for i in range(_data["hp"].size()):
		if _data["hp"][i] >= 0:
			count += 1
	return count

func add_blob(idx : int) -> void:
	if not (idx >= 0 and idx < _data["hp"].size()): return
	if _data["hp"][idx] >= 0: return
	_data["hp"][idx] = 100.0
	blob_added.emit(idx)

func is_blob_active(idx : int) -> bool:
	if not (idx >= 0 and idx < _data["hp"].size()): return false
	return _data["hp"][idx] >= 0

func get_blob_health(idx : int) -> float:
	if not (idx >= 0 and idx < _data["hp"].size()): return -1.0
	return _data["hp"][idx]

func get_oxygen_percentage() -> float:
	return _data["oxy"] / INIT_OXYGEN

func get_fruit_count() -> int:
	return _data["fruits"]

func add_fruit(amount : int = 1) -> void:
	if amount <= 0: return
	_data["fruits"] += amount
	fruits_changed.emit(_data["fruits"])

func hurt(amount : float) -> void:
	if amount <= 0: return # Below threshold :)
	var idx = _RandomActiveBlobIndex()
	if idx < 0: return # Nothing to hurt anymore!
	if _data["hp"][BLOB_DEFENSE_INDEX] > 0:
		amount *= BLOB_DEFENSE_MULTIPLIER
	_data["hp"] = max(0.0, _data["hp"][idx] - amount)
	if _data["hp"][idx] < 0.001:
		_data["hp"][idx] = 0.0
		blob_dead.emit(idx)
	else:
		blob_hp_changed.emit(idx, _data["hp"][idx], INIT_HP)
	
	for i in range(_data["hp"].size()):
		if _data["hp"][i] > 0.0: return
	dead.emit()

func heal(amount : float) -> void:
	if amount <= 0: return
	var blobs : int = blob_count()
	amount = amount / float(blobs)
	for i in range(_data["hp"].size()):
		if _data["hp"][i] < 0: continue
		_data["hp"][i] = min(100.0, _data["hp"][i] + amount)
		blob_hp_changed.emit(i, _data["hp"][i], INIT_HP)

func breath() -> void:
	var blobs : int = blob_count()
	var amount : float = BREATH_OXY_USAGE * blobs
	if _data["hp"][BLOB_OXY_INDEX] > 0:
		amount *= BLOB_OXY_MULTIPLIER
	_data["oxy"] = max(0.0, _data["oxy"] - (amount / float(blobs)))
	if _data["oxy"] <= 0.001:
		hurt(SUFFICATION_DAMAGE)
	oxy_changed.emit(_data["oxy"], INIT_OXYGEN)

func use_fruit() -> void:
	if _data["fruits"] <= 0: return
	_data["fruits"] -= 1
	fruits_changed.emit(_data["fruits"])
	var amount : float = FRUIT_OXY_AMOUNT
	if _data["hp"][BLOB_OXY_INDEX] > 0:
		amount *= (1/BLOB_OXY_MULTIPLIER)
	_data["oxy"] = min(INIT_OXYGEN, _data["oxy"] + amount)
	oxy_changed.emit(_data["oxy"], INIT_OXYGEN)


