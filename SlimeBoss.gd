extends CharacterBody2D


const speed = 150.0
const JUMP_VELOCITY = -500.0
var direction = Vector2.RIGHT

# Randomly jump
var can_jump = true
var jumping = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#idle_ai()
	if is_on_wall():		#If touched wall, change direction
		direction.x *= -1	
		velocity.x = direction.x * speed
	if is_on_floor():
		velocity.x = 0
	# Jump 
	if can_jump:
		can_jump = false
		velocity.y = JUMP_VELOCITY
		velocity.x = direction.x * speed
		print("jump")
		jumping = true
		$JumpTimer.start()

	move_and_slide()
	
func idle_ai():
	$Sprite2D.modulate = Color(1, 1, 0)		#Green 
		
	if is_on_wall():		#If touched wall, change direction
		direction.x *= -1	
		velocity.x = speed * direction.x  # Update velocity with new direction
	velocity.x = speed * direction.x 


func _on_jump_timer_timeout():
	can_jump = true
