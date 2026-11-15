extends Node2D
const BALL = preload("res://ball.tscn")

@onready var hole: Area2D = $hole
@onready var score: Label = $UI/score_label
@onready var hide1: AnimatedSprite2D = $Heart3/AnimatedSprite2D
@onready var hide2: AnimatedSprite2D = $Heart2/AnimatedSprite2D3
@onready var hide3: AnimatedSprite2D = $Heart1/AnimatedSprite2D2
var health = 3 
# index 0 = heart lost last (left), index 2 = heart lost first (right)
@onready var hearts: Array = [$Heart1, $Heart2, $Heart3]
@onready var heart_sprites: Array = [hide3, hide2, hide1]
@onready var heart_stops: Array = [
	get_node("HeartStops/StaticBody2D/HeartStop"),
	get_node("HeartStops/StaticBody2D2/2ndHeartStop"),
	get_node("HeartStops/StaticBody2D3/3rdHeartStop"),
]
var heart_start: Array = []
# each heart can be won back at most twice; shown by white dots on its top left
var heart_lives: Array = [2, 2, 2]
var heart_dots: Array = [[], [], []]

const SHOOT_COOLDOWN = 0.4 # seconds between shots
var last_shot_ms: int = -100000

const AUTO_SHOOT_TIME = 3.0 # seconds you have to shoot before it shoots for you
var shoot_time_left: float = AUTO_SHOOT_TIME
var timer_label: Label
var list_of_bg = ["blue", "red", "green", "yellow"]
#const BACKGROUNDS = {
#	"blue" : preload("res://mesh-gradient (2).png"),
#	"red" : preload("res://mesh-gradient (1).png"),
#	"yellow" : preload("res://mesh-gradient (3).png"),
#	"green" : preload("res://mesh-gradient.png"),
#	"default" : preload("res://mesh-gradient (4).png")
#}

var goals: int

var ball_hit_side = ""
#@onready var background: Sprite2D = $background

func _ready() -> void:
	goals = 0
	for heart in hearts:
		heart_start.append(heart.global_transform)
	for i in hearts.size():
		for d in 2:
			var dot := ColorRect.new()
			dot.color = Color.WHITE
			dot.size = Vector2(7, 7)
			dot.position = heart_sprites[i].position + Vector2(-45 + d * 12, -42)
			hearts[i].add_child(dot)
			heart_dots[i].append(dot)
	# countdown label under the score, same style as the score
	timer_label = score.duplicate()
	timer_label.position = Vector2(0, 70)
	$UI.add_child(timer_label)
#	background.z_index = -1          
	set_background("default")           


func set_background(bg_name: String) -> void:
#	if not BACKGROUNDS.has(bg_name):
		push_warning("Unknown background: " + bg_name)
		return
#	background.texture = BACKGROUNDS[bg_name]
	
	


func _on_timer_timeout() -> void:
	if list_of_bg:
		var bg = list_of_bg.pop_front()
		set_background(bg)

func reset():
	set_background("default")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		health -= 1
		$hit.play()
		body.queue_free()
		reset()
func _process(delta: float) -> void:
	health = max(health, 0)
	# auto shoot if you wait too long
	shoot_time_left -= delta
	if shoot_time_left <= 0:
		shoot()
	timer_label.text = "%.1f" % max(shoot_time_left, 0.0)
	if shoot_time_left < 1.0:
		timer_label.add_theme_color_override("font_color", Color(0.85, 0.1, 0.1))
	else:
		timer_label.add_theme_color_override("font_color", score.get_theme_color("font_color"))
	# a heart drops (and can be won back) depending on how much health you have
	for i in hearts.size():
		if health <= i:
			drop_heart(i)
		else:
			restore_heart(i)

	# hit the most recently lost heart with a ball while it's falling to get it back
	if health < 3:
		var heart_sprite: AnimatedSprite2D = heart_sprites[health]
		if heart_sprite.global_position.y < 720 and heart_lives[health] > 0:
			for ball in get_tree().get_nodes_in_group("balls"):
				if ball.global_position.distance_to(heart_sprite.global_position) < 55:
					heart_lives[health] -= 1
					heart_dots[health][heart_lives[health]].hide()
					health += 1
					ball.queue_free()
					break

	if health <= 0:
		# only game over once the last heart has fallen off the bottom of the screen
		if hide3.global_position.y > 720:
			get_tree().set_meta("last_score", goals) # so the game over screen can show it
			get_tree().change_scene_to_file("res://death.tscn")
		
		
func drop_heart(i: int) -> void:
	var stop: CollisionShape2D = heart_stops[i]
	if not stop.disabled:
		stop.set_deferred("disabled", true)
		hearts[i].sleeping = false

func restore_heart(i: int) -> void:
	var stop: CollisionShape2D = heart_stops[i]
	if stop.disabled:
		var heart: RigidBody2D = hearts[i]
		heart.linear_velocity = Vector2.ZERO
		heart.angular_velocity = 0
		PhysicsServer2D.body_set_state(heart.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, heart_start[i])
		heart.global_transform = heart_start[i]
		stop.set_deferred("disabled", false)

func _input(event):
	if event.is_action_pressed(&"click"):
		if Time.get_ticks_msec() - last_shot_ms < SHOOT_COOLDOWN * 1000:
			return
		shoot()

func shoot():
	last_shot_ms = Time.get_ticks_msec()
	shoot_time_left = AUTO_SHOOT_TIME
	var direction = (get_global_mouse_position() - $Player.global_position).normalized()
	var new_ball = BALL.instantiate()
	new_ball.player = $Player
	new_ball.direction = direction
	new_ball.needs_reset = true
	new_ball.global_position = $Player.global_position + direction * 100
	add_child(new_ball)
	$shoot.play()


func _on_hole_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		goals += 1
		score.text = "Score: " + str(goals)
		$goal.play()
		hole.spawn_choose()
		hole.inc_difficulty(goals <= 13) # goal stops shrinking after score 13
		body.queue_free()
		print(goals)


func _on_rand_dir_change_timeout() -> void:
	hole.switch_dir()
