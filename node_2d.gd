extends Node2D

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
