extends Node2D


@onready var hide1: AnimatedSprite2D = $AnimatedSprite2D
@onready var hide2: AnimatedSprite2D = $AnimatedSprite2D3
@onready var ball: RigidBody2D = $ball
var health = 3 
var list_of_bg = ["blue", "red", "green", "yellow"]
const BACKGROUNDS = {
	"blue" : preload("res://mesh-gradient (2).png"),
	"red" : preload("res://mesh-gradient (1).png"),
	"yellow" : preload("res://mesh-gradient (3).png"),
	"green" : preload("res://mesh-gradient.png"),
	"default" : preload("res://mesh-gradient (4).png")
}


var ball_hit_side = ""
@onready var background: Sprite2D = $background


func _ready() -> void:
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
	ball.reposition()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "ball":
		health -= 1
		reset()
func _process(delta: float) -> void:
	if health == 2: 
		hide1.hide_it()
	if health == 1:
		hide2.hide_it()
		
