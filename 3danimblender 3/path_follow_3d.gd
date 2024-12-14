extends PathFollow3D

var speed = 0.1  # Speed of movement along the path
var direction = 1  # 1 for forward, -1 for backward

func _physics_process(delta):
	progress_ratio += direction * delta * speed

	# Reverse direction when reaching the end or start of the path
	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		direction = -1
	elif progress_ratio <= 0.0:
		progress_ratio = 0.0
		direction = 1
