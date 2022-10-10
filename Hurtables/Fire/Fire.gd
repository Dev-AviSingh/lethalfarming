extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var damageInflicted = 10
var bodyPartDamaged = "full"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var overlappings = $Area2D.get_overlapping_bodies()
	for overlapping in overlappings:
		if overlapping.has_method("getHit"):
			overlapping.getHit(damageInflicted, bodyPartDamaged, self)
