extends CharacterBody2D

# Physics
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Double Jump
var jump_count = 0
var max_jumps = 1

# Coyote Timer
@onready var coyote_timer = $CoyoteJump

# Attacking
var attacking = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Get direction of user input.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Move based on direction (value 1 for right, -1 for left)
	if direction:
		velocity.x = direction * SPEED
	else: # Idle
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Stuff for jumping
	jump()
	
	# Stuff for attacking
	if Input.is_action_just_pressed("ui_attack"):
		attack()
	
	# Coyote Timer - Checks if player is leaving ledge and about to jump
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()

func jump():
	# Handle jump.
	if Input.is_action_just_pressed("ui_select") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	#Reset jump count after falling down
	if is_on_floor() or coyote_timer.time_left > 0.0:
		jump_count = 0	

func attack():
	
	var hit_list = $AttackArea.get_overlapping_bodies()
	
	for area in hit_list:
		var parent = area.get_parent()
		print(parent)
	attacking = true
	
	
