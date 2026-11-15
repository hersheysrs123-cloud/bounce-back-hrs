extends Node2D
const BALL = preload("res://ball.tscn")

@onready var hole: Area2D = $hole
@onready var score: Label = $UI/score_label
@onready var hide1: AnimatedSprite2D = $AnimatedSprite2D
@onready var hide2: AnimatedSprite2D = $AnimatedSprite2D3
var health = 3 
var list_of_bg = ["blue", "red", "green", "yellow"]
const BACKGROUNDS = {
	"blue" : preload("res://mesh-gradient (2).png"),
	"red" : preload("res://mesh-gradient (1).png"),
	"yellow" : preload("res://mesh-gradient (3).png"),
	"green" : preload("res://mesh-gradient.png"),
	"default" : preload("res://mesh-gradient (4).png")
}

var goals: int

var ball_hit_side = ""
@onready var background: Sprite2D = $background

func _ready() -> void:
	goals = 0
	background.z_index = -1          
	set_background("default")           


func set_background(bg_name: String) -> void:
	if not BACKGROUNDS.has(bg_name):
		push_warning("Unknown background: " + bg_name)
		return
	background.texture = BACKGROUNDS[bg_name]
	
	


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
	if health == 2: 
		hide1.hide()
	if health == 1:
		hide2.hide()
#	if health == 0:
		
		
func _input(event):
	if event.is_action_pressed(&"click"):
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
		hole.inc_difficulty()
		body.queue_free()
		print(goals)


func _on_rand_dir_change_timeout() -> void:
	hole.switch_dir()
