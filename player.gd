extends CharacterBody2D


const SPEED = 300.0
@onready var _player = $animation

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	
func _process(_delta):
	var dir := Input.get_vector("left", "right", "up", "down")
	if dir:
		_player.play("move")
	else:
		_player.stop()
