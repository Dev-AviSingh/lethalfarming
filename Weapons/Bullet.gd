extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity:Vector2 = Vector2.RIGHT
var damage = 10
var staticBodyPassCountLimit = 1
var staticBodyPassCount = 0

func nameTagForHackySolutionPleaseEraseMe():
	pass

var limits:Vector2
var limitMargin:int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	limits = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(velocity * delta)
	var colliders = get_overlapping_bodies()
	
	if position.x < 0 - limitMargin or position.x > limits.x*10 + limitMargin:
		queue_free()
	if position.y < 0 - limitMargin or position.y > limits.y + limitMargin:
		queue_free()
	
	for collider in colliders:
		# The following condition covers all the barriers and players.
		if collider is KinematicBody2D and collider.has_method("getHit"):
			var bodyPart = "full"			
			if global_position.y < collider.global_position.y - 18:
				bodyPart = "head"
			elif global_position.y >= collider.global_position.y:
				bodyPart = "legs"
			else:
				bodyPart = "torso"
			collider.getHit(damage, bodyPart, self)
			queue_free()
		if collider is StaticBody2D:
			staticBodyPassCount += 1
			if staticBodyPassCount == staticBodyPassCountLimit:
				queue_free()
