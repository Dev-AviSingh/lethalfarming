extends KinematicBody2D


var health:float = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func getHit(damage:float, bodyPart:String, hitter:Node2D):
	health -= damage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		queue_free()
