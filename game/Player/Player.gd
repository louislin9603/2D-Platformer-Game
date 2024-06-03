extends CharacterBody2D
class_name Player

# Physics
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Jumping
var jump_count = 0
var max_jumps = 1
@onready var coyote_timer = $Timers/CoyoteJump   # Coyote Timer

# Attacking
var attacking = false
var can_attack = true
var enemy_in_range = false
@onready var attack_timer = $Timers/AttackTimer

# Shooting
var shooting = false
var can_shoot = true
var bullet_direction
@onready var bulletPath = preload("res://game/Player/Bullet.tscn")  # Bullet is loaded when scene is loaded
@onready var shoot_timer = $Timers/ShootTimer

# Health
@export var max_health = 4
@onready var health
var can_take_damage = true     # Used for iframes
@onready var health_bar = $"UI/Healthbar"

# Death
var dead = false

# Dashing
var dashing = false
var dash_speed = 1000
var dash_duration = 0.2
var can_dash = true
@onready var dash_timer = $Timers/DashTimer
@onready var can_dash_timer = $Timers/DashAgainTimer    # 1 sec CD

func _ready():
	health = max_health   # Set current health to max when spawned
	health_bar.init_health(health)  # Set health bar to max health
	
func _physics_process(delta):
	
	## Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	## Stuff for moving and dashing
	movement()   
	if Input.is_action_just_pressed("ui_dash") and can_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		can_dash_timer.start()
	
	# Stuff for jumping
	jump()
	
	## Falling out of the map
	if global_position.y > 985:
		death()
	
	## Stuff for attacking 
	if Input.is_action_pressed("ui_right"):               # Set attack area on the right of player
		get_node("AttackArea").set_scale(Vector2(1, 1))
		$ShootArea.scale.x = 1
	elif Input.is_action_pressed("ui_left"):              # Set a ttack area on the left of playeer
		get_node("AttackArea").set_scale(Vector2(-1, 1))
		$ShootArea.scale.x = -1
	
	if Input.is_action_pressed("ui_attack") and can_attack:
		attack()
		attack_timer.start()
	else:
		attacking = false
	
	# Stuff for shooting
	if Input.is_action_just_pressed("ui_shoot") and can_shoot:
		shoot()
		shoot_timer.start()
	else:
		shooting = false
	
	# Coyote Timer - Checks if player is leaving ledge and about to jump
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()

func movement():
	# Get direction of user input.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Move based on direction (value 1 for right, -1 for left)
	if direction:
		if dashing:          # Dash mechanic
			var dash_direction = Vector2.ZERO
			if Input.is_action_pressed("ui_right"):
				dash_direction.x += 1
			if Input.is_action_pressed("ui_left"):
				dash_direction.x -= 1
			velocity = dash_direction.normalized() * dash_speed
		
		else:
			velocity.x = direction * SPEED
	else: # Idle
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Fall down one way platforms
	if Input.is_action_pressed("ui_down") and is_on_floor():
		position.y += 1

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
	
	# If enemy is within attack area range
	if enemy_in_range == true and attacking == true:
		var hit_list = $AttackArea.get_overlapping_areas()
		for area in hit_list:
			var parent = area.get_parent()
			print(parent)
			parent.take_damage(2)
		can_attack = false

func shoot():
	shooting = true
	var bullet = bulletPath.instantiate()      # Pulls the preloaded bullet scene
	
	bullet.position = $ShootArea/Shoot.global_position 
	bullet.velocity_placeholder = $ShootArea.scale.x
	get_parent().add_child(bullet)
	
	can_shoot = false

func take_damage(damage_amount):
	if can_take_damage:
		iframes()
		
		health -= damage_amount
		print(health)
		health_bar.health = health

	if health <= 0:
			death()

func death():
	if not dead:
		dead = true
		velocity = Vector2.ZERO
		print("dead")
		self.health = self.max_health     #Reset player hp
		get_tree().reload_current_scene()

func iframes():
	can_take_damage = false
	$Sprite2D.modulate = Color.WEB_PURPLE
	await get_tree().create_timer(1).timeout       #One second iframe
	$Sprite2D.modulate = Color.WHITE
	can_take_damage = true
	

func _on_attack_area_body_entered(body):
	# If a body enters player attack range
	if body and body.name != "TileMap" and body.name != "Player":
		enemy_in_range = true
		

func _on_attack_area_body_exited(body):
	# If a body exits player attack range
	if body and body.name != "TileMap" and body.name != "Player":
		enemy_in_range = false

# Make it stop dashing
func _on_dash_timer_timeout():
	dashing = false

# Allow dash again
func _on_dash_again_timer_timeout():
	can_dash = true

# Allow shoot again
func _on_shoot_timer_timeout():
	can_shoot = true

# Allow attack again
func _on_attack_timer_timeout():
	can_attack = true
