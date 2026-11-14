extends RigidBody2D
var needs_reset = false

@export var speed: float = 400.0
var start_position: Vector2
func _ready() -> void:
	linear_velocity = Vector2(1,1).normalized()*speed
	start_position = global_position

func reposition():
	needs_reset = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if needs_reset:
		needs_reset = false
		state.transform.origin = start_position  
		state.linear_velocity = Vector2(1, 1).normalized()*speed
		state.angular_velocity = 0
		return 
		
