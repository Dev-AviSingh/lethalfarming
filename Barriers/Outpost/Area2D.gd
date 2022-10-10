extends Area2D


var parent:KinematicBody2D
var changeOpacityTimer:Timer
var allowReset:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	changeOpacityTimer = Timer.new()
	changeOpacityTimer.connect("timeout", self, "resetOpacity")
	changeOpacityTimer.one_shot = true
	changeOpacityTimer.wait_time = 1
	add_child(changeOpacityTimer)

func resetOpacity():
	allowReset = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for x in get_overlapping_bodies():
		if x is KinematicBody2D and not "Outpost" in x.name:
			modulate.a = 0.1
		
	#print(modulate.a, " ", allowReset)
	modulate.a = lerp(modulate.a, 1, 0.2)
