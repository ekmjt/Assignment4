extends Node3D
var fixed: Camera3D
var dynamic: Camera3D
var current: Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fixed = $StaticCam
	dynamic = $MovingCam
	
	current = fixed
	fixed.current = true
	dynamic.current = false
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("Switch"):
		selectCam()
		
func selectCam():
	if current == fixed:
		current = dynamic
		fixed.current = false
		dynamic.current = true
	else:
		current = fixed
		fixed.current = true
		dynamic.current = false
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
