extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

# Variables for double jump
var jump_count = 0
var max_jumps = 1

# Variables for wall slide
const WALL_SLIDE_ACCELERATION = 10
const MAX_WALL_SLIDE_SPEED = 80

# Coyote Timer
@onready var coyote_timer = $CoyoteJump

# Variables for dashing
var dash_direction = Vector2(1,0)
var canDash = false
var dashing = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	
	dash()
	
	if dashing:
		velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
		move_and_slide()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		
		# Jump while on wall
		if is_on_wall() and Input.is_action_pressed("ui_right"):
			velocity.y = JUMP_VELOCITY
			velocity.x = direction * -SPEED
			
		elif is_on_wall() and Input.is_action_pressed("ui_left"):
			velocity.y = JUMP_VELOCITY
			velocity.x = direction * SPEED
			
		
	# Wall slide
	if is_on_wall() and (Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left")):
		if velocity.y >= 0:
			velocity.y = min(velocity.y + WALL_SLIDE_ACCELERATION, MAX_WALL_SLIDE_SPEED)
		jump_count = 0	
	else: 
		velocity.y += gravity/4 * delta
			
	#Reset jump count after falling down
	if is_on_floor() or coyote_timer.time_left > 0.0:
		jump_count = 0
		
	if direction:
		velocity.x = direction * SPEED
		dash()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Coyote Timer - Checks if player is leaving ledge and about to jump
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()

func dash():
	if is_on_floor():
		canDash = true
	
	if Input.is_action_pressed("ui_right"):
		dash_direction = Vector2.RIGHT
	if Input.is_action_pressed("ui_left"):
		dash_direction = Vector2.LEFT
		
	if Input.is_action_just_pressed("ui_dash") and canDash:
		velocity = dash_direction.normalized() * 2000
		canDash = false
		dashing = true
		await get_tree().create_timer(0.3).timeout
		dashing = false
