extends RigidBody2D

var needs_reset = false
@export var player: Node2D
@export var speed: float = 400.0
var target: Vector2
var direction: Vector2
var bounce_turn: float = 0.0

func reposition():
	needs_reset = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if needs_reset:
		needs_reset = false
		target = player.global_position
		state.transform.origin = target + direction * 100
		state.linear_velocity = direction.normalized() * speed
		state.angular_velocity = 0
		return 
		
	if bounce_turn != 0.0:
		state.linear_velocity = state.linear_velocity.rotated(bounce_turn)
		bounce_turn = 0.0

	if state.linear_velocity.length() > 0:
		state.linear_velocity = state.linear_velocity.normalized() * speed
	
	


func _on_body_entered(body: Node) -> void:
	if body is StaticBody2D:
		$bounce.play()
		bounce_turn = randf_range(-0.25, 0.25)
		


func _on_despawn_timeout() -> void:
	queue_free()
