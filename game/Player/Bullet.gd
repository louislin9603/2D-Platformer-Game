extends CharacterBody2D

var speed = 700
var velocity_placeholder : float

var terrain = [
	"TileMap",
	"MovingPlatform",
	"BrokenPlatform",
	"OneWayPlatform"
]


func _physics_process(delta):
	
	move_local_x(velocity_placeholder * speed * delta)

func _on_hit_detector_body_entered(body):
	
	# If bullet hits an enemy in group "Enemy"
	if body.is_in_group("Enemy"):
		self.queue_free()
		body.take_damage(1)
		print(body.health)
	
	# If bullet hits terrain defined above, disappear
	if body.name in terrain:
		self.queue_free()
	
