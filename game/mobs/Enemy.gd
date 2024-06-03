extends CharacterBody2D
class_name Enemy

var player 

# Physics
var speed = 40.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Health
@onready var health_bar = $Healthbar
var health 
var max_health = 3
var can_take_damage = true

# Enemy AI 
var chase = false
var chase_speed = 90
var direction = Vector2.RIGHT
var can_move
var idle_duration_range = Vector2(2.0, 5.0)
var idle_duration = 0.0
var idle_timer = 0.0

func _ready():
	health = max_health 
	health_bar.init_health(health)
	
	can_move = true

func _physics_process(delta):
	

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# If player enters detection zone
	if chase:
		chase_player()
	else:
		idle_ai()
		
		# Enemy stops moving periodically
		if can_move: # Idle AI		
			idle_timer += delta
			if idle_timer >= idle_duration:
				can_move = false
				idle_timer = 0.0
				velocity.x = 0
				
		else:
			idle_timer += delta
			if idle_timer >= 1.0:
				can_move = true
				idle_timer = 0.0
				idle_duration = randi_range(5,13)   # Stops moving every 5-13 seconds, random
				velocity.x = speed * direction.x
		
		
	move_and_slide()

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
		player = body       #The entity that just entered the detection range is the body (our player)

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		chase = false
		
func chase_player():
	$Sprite2D.modulate = Color(1, 0, 0)		#Red for angry
	direction = (player.global_position - self.global_position).normalized()
	velocity.x = direction.x * chase_speed

func idle_ai():
	$Sprite2D.modulate = Color(0, 1, 0)		#Green 
	
	if is_on_wall():		#If touched wall, change direction
		direction.x *= -1	
		velocity.x = speed * direction.x  # Update velocity with new direction
	if !$"Edge Detection/RayCast_R".is_colliding() or !$"Edge Detection/RayCast_L".is_colliding():	#If touched ledge of a cliff
		direction.x *= -1  
		velocity.x = speed * direction.x 
	#velocity.x = speed * direction.x 

func take_damage(damage_amount):
	if can_take_damage:
		iframes()
		
		health -= damage_amount
		print(health)
		health_bar.health = health

	if health <= 0:
			self.queue_free()

func iframes():
	can_take_damage = false
	$Sprite2D.modulate = Color.WEB_PURPLE
	await get_tree().create_timer(0.1).timeout       #One second iframe
	$Sprite2D.modulate = Color.WHITE
	can_take_damage = true
	
func _on_temp_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(1)

