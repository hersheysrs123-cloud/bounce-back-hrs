extends ColorRect

@export var change_time: float = 1.0   # seconds per colour change

func _ready() -> void:
	change_color()

func change_color() -> void:
	var target := Color(randf(), randf(), randf())   # random colour, each channel 0–1
	var tween := create_tween()
	tween.tween_property(self, "color", target, change_time)
	tween.tween_callback(change_color)   # when it finishes, start the next one
