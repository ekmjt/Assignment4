extends CharacterBody3D


@onready var ball1 = $"../Ball1"

@onready var attach = $Armature/Skeleton3D/BoneAttachment3D
@onready var skeleton = $Armature/Skeleton3D
@onready var raycast = $Armature/RayCast3D
@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D
@onready var armature = $Armature
@onready var anim_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var hand = $Armature/RayCast3D/hand
@onready var joint = $Armature/RayCast3D/Generic6DOFJoint3D
@onready var staticbody = $Armature/RayCast3D/StaticBody3D
var is_grabbing: bool = false
var is_holding: bool = false
var object_held: Object = null
var pull_power: float = 4.0
var locked = false


const SPEED: float = 5.0
const LERP_VAL: float = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_x(-event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI / 4, PI / 4)

func _input(_event):
	if Input.is_action_just_pressed("grab"):
		if not is_grabbing:
			animation_player.play("grab")
			pickup_item()
			is_holding = true
			animation_player.queue("pickup")
			is_grabbing = true

	elif Input.is_action_just_pressed("letgo"):
		if is_grabbing:
			animation_player.play("letgo")
			drop_item()
			is_holding = false
			is_grabbing = false

func pickup_item():
	if raycast.is_colliding():
		object_held = raycast.get_collider()
		if object_held != null:
			object_held.set_freeze_enabled(true)
			add_child(object_held)

func drop_item():
	if object_held != null:
		remove_child(object_held)
		object_held.set_freeze_enabled(false)
		object_held = null

func _physics_process(delta):
	# Update the position of the held object to match the attach point
	if object_held != null:
		var offset = Vector3(-3, 0, -0.5)  # Adjust offset values as needed
		var global_offset = attach.global_transform.basis * offset  # Correctly apply the offset
		object_held.global_transform.origin = attach.global_transform.origin + global_offset
		object_held.global_transform = attach.global_transform
		
		

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0  # Reset vertical velocity when on the ground

	# Handle movement input
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)

	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Move the character using move_and_slide
	move_and_slide()
