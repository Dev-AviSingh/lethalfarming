extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var spawnDelay = 5
var spawnedEnemies = []
export var spawnLimit = 15

var allowSpawn = true
var spawnTimer:Timer


var enemyTemplate = preload("res://Enemy/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnTimer = Timer.new()
	add_child(spawnTimer)
	spawnTimer.connect("timeout", self, "enableSpawn")
	spawnTimer.wait_time = spawnDelay
	spawnTimer.one_shot = true

func enableSpawn():
	allowSpawn = true

func spawnEnemy():
	var enemy:KinematicBody2D = enemyTemplate.instance()
	enemy.spawner = self
	get_parent().add_child(enemy)
	enemy.global_position = $Position2D.global_position
	allowSpawn = false
	spawnTimer.start(spawnDelay)
	
	spawnedEnemies.append(enemy)

func removeEnemy(enemy):
	spawnedEnemies.erase(enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if allowSpawn and spawnedEnemies.size() < spawnLimit:
		spawnEnemy()
	#clearNullEnemies()
	#print(spawnedEnemies)
