extends CharacterBody3D

# Node references
@onready var camera = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D
@onready var armature = $Armature
@onready var animation_player = $AnimationPlayer
@onready var skeleton = $Armature/Skeleton3D
@onready var Ray_Cast = $Armature/RayCast3D
@onready var grabbing_area = $Armature/GrabbingArea
@onready var ball_material = $"../Ball/MeshInstance3D".material_override
@onready var GoalArea = $"../Path3D/PathFollow3D/Goal2/Area3D"
@onready var ball = $"../Ball"
@onready var score_label = $"../CanvasLayer/Label"          # Reference to the Score Label
@onready var controls_label = $"../CanvasLayer/Label2"      # Reference to the Controls Label
@onready var goal_label = $"../CanvasLayer/GoalLabel"       # Reference to the GOAL Label
@onready var goal_sound = $"../GoalSound"                   # Reference to the AudioStreamPlayer node
@onready var play_button = $"../CanvasLayer/PlayButton"     # Reference to the Play Button
@onready var Background_music= $"../Background"
# Exported variables
@export_group("Arm Movement")
@export var ArmSpeed: float = 5.0
@export var xclr8: float = 7.5
@export var jumpDist: float = 4.5
@export var gravity: float = 9.8

@export_group("Holding Objects")
@export var throwPower: float = 50.0
@export var pullSpeed: float = 10.2
@export var following: float = 2.5
@export var pick_up_speed: float = 0.5

@export_group("Goal Animation")
@export var letter_delay: float = 0.3  # Delay between each letter animation

# Variables
var game_started: bool = false  # Track if the game has started
var movDirection: Vector3
var object_held: RigidBody3D
var is_animating: bool = false
var can_grab: bool = false
var score: int = 0
var initial_ball_position: Vector3

# New statistics
var total_shots: int = 0
var invalid_goals: int = 0

func _ready():
	print("Game initialized")
	Background_music.play()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	initial_ball_position = ball.global_transform.origin

	
	grabbing_area.connect("body_entered", Callable(self, "_on_body_entered"))
	grabbing_area.connect("body_exited", Callable(self, "_on_body_exited"))
	GoalArea.connect("body_entered", Callable(self, "_on_goal_entered"))
	play_button.connect("pressed", Callable(self, "_on_play_button_pressed"))

	# Initialize labels and sounds
	update_score_display()
	update_controls_label()
	setup_goal_label()

	# Position and scale labels
	setup_labels()

	# Show Play Button at the start
	play_button.visible = true
	game_started = false

func setup_labels():
	print("Setting up labels")
	var window_size = DisplayServer.window_get_size()

	score_label.position = Vector2(50, 20)  # Top-left corner
	score_label.custom_minimum_size = Vector2(400, 100)
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.modulate = Color(0, 0, 0)
	controls_label.position = Vector2(820, window_size.y - 320)  #Bottom-right?
	controls_label.custom_minimum_size = Vector2(600, 200)
	controls_label.add_theme_font_size_override("font_size", 20)
	controls_label.modulate = Color(0, 0, 0)
	
	goal_label.position = Vector2((window_size.x / 2) - 200, 50)  # Top-center
	goal_label.custom_minimum_size = Vector2(800, 200)
	goal_label.add_theme_font_size_override("font_size", 100)
	goal_label.modulate = Color(1, 1, 0)  #Need to change the color, not visible when looking at sky.
	goal_label.visible = false

	play_button.position = Vector2((window_size.x / 2) - 225, window_size.y / 2)  # Center the button
	play_button.text = "Click Anywhere to Play"
	play_button.custom_minimum_size = Vector2(200, 100)
	play_button.add_theme_font_size_override("font_size", 36)

func setup_goal_label():
	print("Setting up goal label")
	goal_label.text = ""

func _on_play_button_pressed():
	print("Play button pressed")
	play_button.visible = false  # Hide the button
	game_started = true  # Start the game

func update_score_display():
	var accuracy: float = 0.0
	if total_shots > 0:
		accuracy = float(score) / float(total_shots) * 100.0
	print("Updating score display: score=", score, " total_shots=", total_shots, " invalid_goals=", invalid_goals, " accuracy=", accuracy)
	score_label.text = "Score: " + str(score) + "\nTotal Shots: " + str(total_shots) + "\nInvalid Goals: " + str(invalid_goals) + "\nAccuracy: " + str(accuracy) + "%"

func update_controls_label():
	print("Updating controls label")
	controls_label.text = """
Controls :-
Movement -> WASD.
Ball changes color when in range.
Press 1 to grab ball.
Press 2 to jump.
Press 3 to throw ball.
Press Esc to Quit.
[Ball Respawns on Ramp]
[Goal Distance should be >5m]
"""

func show_goal_label():
	print("Showing GOAL label")
	goal_label.visible = true
	goal_sound.play()  # Play the goal sound
	await animate_goal_text("GOAL!!!")  # Animate the "GOAL" text
	await get_tree().create_timer(1.0).timeout  # Keep it on-screen for an additional 1 second
	goal_label.visible = false
	goal_label.text = ""  # Reset the text

func animate_goal_text(text: String):
	print("Animating goal text: ", text)
	goal_label.text = ""  # Clear existing text
	for i in range(text.length()):
		goal_label.text += text[i]  # Add one letter at a time
		await get_tree().create_timer(letter_delay).timeout  # Wait for the delay

func _process(delta):
	if not game_started:
		return  # Skip all game logic until the game starts

	var inputpath = Input.get_vector("left", "right", "forward", "back")
	movDirection = (transform.basis * Vector3(inputpath.x, 0, inputpath.y)).normalized()

	if Input.is_action_just_pressed("quit"):
		print("Quit action detected")
		get_tree().quit()

	if Input.is_action_just_pressed("pick") and is_on_floor(): 
		print("Jump action detected")
		velocity.y = jumpDist #Anurag please change the action name to jump corresponding do key '2'

	if object_held:
		move_object_toward_target(delta)

func _physics_process(delta):
	if not game_started:
		return  # Skip all game logic until the game starts

	control_holding_objects()

	if not is_on_floor(): 
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("pick") and is_on_floor():
		velocity.y = jumpDist

	velocity.x = lerp(velocity.x, movDirection.x * ArmSpeed, xclr8 * delta)
	velocity.z = lerp(velocity.z, movDirection.z * ArmSpeed, xclr8 * delta)

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.01)
		camera.rotate_x(-event.relative.y * 0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func set_object_held(body):
	if body is RigidBody3D and can_grab:
		print("Setting object as held: ", body.name)
		is_animating = true
		animation_player.play("grab")  # Play the grab animation
		await animation_player.animation_finished
		object_held = body  # Set the object as held after grab animation completes
		animation_player.play("pickup")  # Play the pickup animation
		await animation_player.animation_finished
		is_animating = false

func move_object_toward_target(delta):
	var target_position = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -following))
	var lerp_speed = pick_up_speed if is_animating else pullSpeed
	object_held.global_transform.origin = object_held.global_transform.origin.lerp(target_position, lerp_speed * delta)

func throwing_object_held():
	if object_held:
		print("Throwing object: ", object_held.name)
		is_animating = true
		animation_player.play("letgo")
		var throw_direction = -camera.global_transform.basis.z
		object_held.apply_central_impulse(throw_direction * throwPower)
		object_held.linear_velocity = throw_direction * throwPower
		object_held = null
		is_animating = false
		# Increment total shots when a throw is made
		total_shots += 1
		update_score_display()
		reset_ball()

func control_holding_objects():
	if is_animating:
		return

	if Input.is_action_just_pressed("letgo"):
		print("Letgo action detected")
		if object_held != null:
			throwing_object_held()
	elif Input.is_action_just_pressed("grab"):
		print("Grab action detected")
		if object_held == null and Ray_Cast.is_colliding() and can_grab:
			set_object_held(Ray_Cast.get_collider())

func _on_body_entered(body):
	if body.name == "Ball":  
		print("Ball entered grabbing area")
		highlight_grabbing_area(true)
		can_grab = true

func _on_body_exited(body):
	if body.name == "Ball":  
		print("Ball exited grabbing area")
		highlight_grabbing_area(false)
		can_grab = false

func _on_goal_entered(body):
	if body.name == "Ball":
		var player_position = global_transform.origin
		var ball_position = ball.global_transform.origin
		var distance = player_position.distance_to(ball_position)

		if distance >= 5.0:
			print("Goal entered by ball with valid distance")
			score += 1
			update_score_display()
			show_goal_label()
			reset_ball()
		else:
			print("Goal entered by ball but distance is less than 5m, not counted")
			invalid_goals += 1
			update_score_display()
			reset_ball()

func reset_ball():
	print("Resetting ball position")
	await get_tree().create_timer(1.0).timeout
	ball.global_transform.origin = initial_ball_position
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO

func highlight_grabbing_area(enable):
	print("Highlighting grabbing area: ", enable)
	if enable:
		ball_material.albedo_color = Color(1, 0, 0)
	else:
		ball_material.albedo_color = Color(1, 1, 1)
