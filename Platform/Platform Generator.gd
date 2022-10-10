extends Node2D


var maxObstacleCount = 100
var limits
var obstacles = []
var obstacleTemplate
var jumpRange = 200



# Called when the node enters the scene tree for the first time.
func _ready():
	limits = get_viewport_rect().size
	obstacleTemplate = preload("res://Platform/Platform.tscn")
	
	var horizontalSpawnRange = [global_position.x, limits.x * 3 + global_position.x]
	var verticalSpawnRange = [global_position.y, limits.y - 150]
	var lastYSpawn = limits.y - 200
	
	for x in range(horizontalSpawnRange[0], horizontalSpawnRange[1], 250):
		var upperSpawnLimit = clamp(lastYSpawn - jumpRange, verticalSpawnRange[0], verticalSpawnRange[1])
		var lowerSpawnLimit = clamp(lastYSpawn + jumpRange, verticalSpawnRange[0], verticalSpawnRange[1])
		
		var y = rand_range(lowerSpawnLimit, upperSpawnLimit)
		var newObstacle = obstacleTemplate.instance()
		
		add_child(newObstacle)
		
		newObstacle.global_position.x = x
		newObstacle.global_position.y = y

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
