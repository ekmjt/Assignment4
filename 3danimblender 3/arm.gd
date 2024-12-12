extends CharacterBody3D

@onready var camera = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D
@onready var armature = $Armature
@onready var anim_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var skeleton = $Armature/Skeleton3D
@onready var Ray_Cast = $Armature/RayCast3D
@onready var grabbing_area = $Armature/GrabbingArea  # Area3D for detecting the ball
@onready var ball_material = $"../Ball/MeshInstance3D".material_override  # Reference to the ball's material

@export_group("Arm movement")
@export var ArmSpeed = 5.0
@export var xclr8 = 7.5
@export var jumpDist = 4.5
@export var gravity = 9.8

@export_group("Holding Objects")
@export var throwPower = 7.5
@export var pullSpeed = 5.0
@export var following = 2.5

@export_group("Arm")
@export var mouse = Vector2(0.2, 0.2)

var movDirection: Vector3
var object_held: RigidBody3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Connect Area3D signals
	grabbing_area.connect("body_entered", Callable(self, "_on_body_entered"))
	grabbing_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(_delta):
	# Input Path
	var inputpath = Input.get_vector("left", "right", "forward", "back")
	movDirection = (transform.basis * Vector3(inputpath.x, 0, inputpath.y)).normalized()

	# Jump
	if Input.is_action_just_pressed("pick") and is_on_floor(): 
		velocity.y = jumpDist

func _physics_process(delta):
	control_holding_objects()

	# Add Gravity
	if !is_on_floor(): 
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("pick") and is_on_floor():
		velocity.y = jumpDist

	# Handling Movement
	velocity.x = lerp(velocity.x, movDirection.x * ArmSpeed, xclr8 * delta)
	velocity.z = lerp(velocity.z, movDirection.z * ArmSpeed, xclr8 * delta)

	move_and_slide()

func _unhandled_input(event):
	# Rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse.x * 0.01)
		camera.rotate_x(-event.relative.y * mouse.y * 0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func set_object_held(body):
	if body is RigidBody3D:
		object_held = body

func dropping_object_held():
	object_held = null

func throwing_object_held():
	var obj = object_held
	dropping_object_held()
	obj.apply_central_impulse(-camera.global_basis.z * throwPower * 10)

func control_holding_objects():
	# Throwing Object
	if Input.is_action_just_pressed("letgo"):
		if object_held != null:
			throwing_object_held()

	# Dropping Object
	if Input.is_action_just_pressed("grab"):
		if object_held != null:
			dropping_object_held()
		elif Ray_Cast.is_colliding():
			set_object_held(Ray_Cast.get_collider())

	# Object Following
	if object_held != null:
		var targetPos = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -following))  # Object held in front of arm
		var objectPos = object_held.global_transform.origin  
		object_held.linear_velocity = (targetPos - objectPos) * pullSpeed 


func _on_body_entered(body):
	if body.name == "Ball":  
		print("Ball entered grabbing area!")
		highlight_grabbing_area(true)

# Handle when a body exits the grabbing area
func _on_body_exited(body):
	if body.name == "Ball":  
		print("Ball exited grabbing area!")
		highlight_grabbing_area(false)


func highlight_grabbing_area(enable):
	if enable:
		ball_material.albedo_color = Color(1, 0, 0)  # Change to red when in grabbing area
	else:
		ball_material.albedo_color = Color(1, 1, 1)  # Reset to white when out of grabbing area
