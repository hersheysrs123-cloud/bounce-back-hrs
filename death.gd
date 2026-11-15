extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# show the score from the run that just ended, under the Try Again button
	var score_label := Label.new()
	score_label.text = "Score: " + str(get_tree().get_meta("last_score", 0))
	score_label.add_theme_font_override("font", load("res://BOUNCY GUM.ttf"))
	score_label.add_theme_font_size_override("font_size", 50)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.position = Vector2(379, 455)
	score_label.size = Vector2(389, 70)
	$CanvasLayer.add_child(score_label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")
