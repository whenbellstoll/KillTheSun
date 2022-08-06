extends Node2D


onready var player = $AnimationPlayer

func _ready():
	player.play("Intro")
	pass

func _process(delta):
	if !player.is_playing():
		get_tree().change_scene("res://Game.tscn")


