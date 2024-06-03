extends Node2D

func _on_player_hit_body_entered(body):
	if body.name == "Player":
		body.take_damage(1)
