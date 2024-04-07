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
var enemy_in_range = false


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
	if Input.is_action_pressed("ui_right"):
		get_node("AttackArea").set_scale(Vector2(1, 1))
	elif Input.is_action_pressed("ui_left"): 
		get_node("AttackArea").set_scale(Vector2(-1, 1))
	
	if Input.is_action_pressed("ui_attack") and attacking == false:
		attack()
	else:
		attacking = false
	
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
		
	attacking = true
	
	if enemy_in_range == true and attacking == true:
		var hit_list = $AttackArea.get_overlapping_areas()
		for area in hit_list:
			var parent = area.get_parent()
			parent.queue_free()

func _on_attack_area_body_entered(body):
	# If a body enters player attack range
	if body and body.name != "TileMap" and body.name != "Player":
		print(body.name)
		enemy_in_range = true
		
		
func _on_attack_area_body_exited(body):
	# If a body exits player attack range
	if body and body.name != "TileMap" and body.name != "Player":
		enemy_in_range = false
