extends CanvasLayer


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	for child in get_children():
		if child.has_signal(&"request"):
			child.request.connect(_on_request)
			child.visible = false


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func show_menu(menu_name : String, return_menu : String = "") -> void:
	#if not get_children().any(func(c : Control): return c.name == menu_name): return
	for child in get_children():
		if child.has_method(&"show_menu"):
			child.show_menu(menu_name, return_menu)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_request(req : Dictionary) -> void:
	if not "request" in req: return
	match req["request"]:
		&"show_menu":
			if not "menu" in req: return
			var _return_menu : String = "" if not "return" in req else req["return"]
			show_menu(req["menu"], _return_menu)
		_:
			request.emit(req)

