extends Area2D

var speed = 100
var direction := Vector2(1, 0)
var wall: int

func _process(delta):
	position += direction * speed * delta
	if wall == 1 or wall == 2:
		if (global_position.y > 617.0 and direction.y > 0) or (global_position.y < 33.0 and direction.y < 0):
			switch_dir()
	else:
		if (global_position.x > 1120.0 and direction.x > 0) or (global_position.x < 34.0 and direction.x < 0):
			switch_dir()
	
func spawn_choose():
	wall = randi_range(1, 4)
	if wall == 1:
		global_position = Vector2(34.0, 283.0)
		rotation = 0
		direction = Vector2(0, 1) if randi() % 2 == 0 else Vector2(0, -1)
	elif wall == 2:
		global_position = Vector2(1120.0, 316.0)
		rotation = PI
		direction = Vector2(0, -1) if randi() % 2 == 0 else Vector2(0, 1)
	elif wall == 3:
		global_position = Vector2(592.0, 33.0)
		rotation = PI / 2
		direction = Vector2(1, 0) if randi() % 2 == 0 else Vector2(-1, 0)
	else:
		global_position = Vector2(583.0, 617.0)
		rotation = -1 * PI / 2
		direction = Vector2(-1, 0) if randi() % 2 == 0 else Vector2(1, 0)
		
func switch_dir():
	$RandDirChange.wait_time = randf_range(3, 10)
	direction *= -1
