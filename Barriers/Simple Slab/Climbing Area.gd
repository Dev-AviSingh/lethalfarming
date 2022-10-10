extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var allowEnemyToClimb = false
var allowPlayerToClimb = true
export var upthrust = 50
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var overlappers = get_overlapping_bodies()
	for body in overlappers:
		if body is KinematicBody2D:
			if "Player" in body.name and allowPlayerToClimb and Input.is_action_pressed("ui_up"):
				if body.acceleration.y >= 0:
					body.velocity.y -= upthrust
			elif "Enemy" in body.name and allowEnemyToClimb:
				if body.acceleration.y >= 0:
					body.acceleration.y -= upthrust
