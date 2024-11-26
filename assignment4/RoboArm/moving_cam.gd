extends Camera3D
var speed:float = 8.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var userInput = Vector3.ZERO
	
	if Input.is_action_pressed("Up"):
		userInput.z -= 1
		
	elif Input.is_action_pressed("Down"):
		userInput.z += 1
		
	elif Input.is_action_pressed("Left"):
		userInput.x -= 1
		
	elif Input.is_action_pressed("Right"):
		userInput.x += 1
	
	userInput = userInput.normalized() * speed * delta
	
	global_transform.origin += global_transform.basis * userInput
	
	look_at(Vector3(0.001,0.769,0))
	pass
