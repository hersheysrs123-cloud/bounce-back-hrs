extends Node2D
const BALL = preload("res://ball.tscn")

@onready var hole: Area2D = $hole
@onready var score: Label = $UI/score_label
@onready var hide1: AnimatedSprite2D = $Heart3/AnimatedSprite2D
@onready var hide2: AnimatedSprite2D = $Heart2/AnimatedSprite2D3
@onready var hide3: AnimatedSprite2D = $Heart1/AnimatedSprite2D2
var health = 3 
@onready var hearts: Array = [$Heart1, $Heart2, $Heart3]
@onready var heart_sprites: Array = [hide3, hide2, hide1]
@onready var heart_stops: Array = [
	get_node("HeartStops/StaticBody2D/HeartStop"),
	get_node("HeartStops/StaticBody2D2/2ndHeartStop"),
	get_node("HeartStops/StaticBody2D3/3rdHeartStop"),
]
var heart_start: Array = []
var heart_lives: Array = [2, 2, 2]
var heart_dots: Array = [[], [], []]

const SHOOT_COOLDOWN = 0.4
var last_shot_ms: int = -100000

const AUTO_SHOOT_TIME = 3.0
var shoot_time_left: float = AUTO_SHOOT_TIME
var timer_label: Label
var list_of_bg = ["blue", "red", "green", "yellow"]

var goals: int

var ball_hit_side = ""

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
	timer_label = score.duplicate()
	timer_label.position = Vector2(0, 70)
	timer_label.text = "%.1f" % AUTO_SHOOT_TIME
	$UI.add_child(timer_label)
	if not get_tree().has_meta("tutorial_shown"):
		get_tree().set_meta("tutorial_shown", true)
		show_tutorial()


func show_tutorial() -> void:
	var tutorial := Label.new()
	tutorial.text = "HOW TO PLAY\n\nMove: WASD / arrow keys\nShoot: click (aims at your mouse)\nBounce balls into the moving goal to score\nDon't let your own balls hit you!\nHit a falling heart to get it back (2 dots = 2 saves)\nShoot before the timer runs out or it shoots for you"
	tutorial.add_theme_font_override("font", load("res://BOUNCY GUM.ttf"))
	tutorial.add_theme_font_size_override("font_size", 26)
	tutorial.add_theme_color_override("font_color", Color.WHITE)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.75)
	bg.set_corner_radius_all(20)
	bg.set_content_margin_all(20)
	tutorial.add_theme_stylebox_override("normal", bg)
	tutorial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial.position = Vector2(176, 134)
	tutorial.size = Vector2(800, 380)
	tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(tutorial)
	get_tree().paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(4.5)
	tween.tween_property(tutorial, "modulate:a", 0.0, 0.5)
	tween.tween_callback(tutorial.queue_free)
	tween.tween_callback(func(): get_tree().paused = false)
	set_background("default")           


func set_background(bg_name: String) -> void:
		push_warning("Unknown background: " + bg_name)
		return
	
	


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
	shoot_time_left -= delta
	if shoot_time_left <= 0:
		shoot()
	timer_label.text = "%.1f" % max(shoot_time_left, 0.0)
	if shoot_time_left < 1.0:
		timer_label.add_theme_color_override("font_color", Color(0.85, 0.1, 0.1))
	else:
		timer_label.add_theme_color_override("font_color", score.get_theme_color("font_color"))
	for i in hearts.size():
		if health <= i:
			drop_heart(i)
		else:
			restore_heart(i)

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
		if hide3.global_position.y > 720:
			get_tree().set_meta("last_score", goals)
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
		hole.inc_difficulty(goals <= 13)
		body.queue_free()
		print(goals)


func _on_rand_dir_change_timeout() -> void:
	hole.switch_dir()
