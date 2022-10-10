extends Node2D


# Only doing horizontal movement
# Creates automatic scrolling background
var spriteFrames = []
var spriteRect
var spriteWidth
var speed = Vector2(50, 0)
var limits

# Called when the node enters the scene tree for the first time.
func _ready():
	spriteFrames = []
	spriteRect = $Sprite.get_rect()
	limits = get_viewport_rect().size
	
	spriteWidth = spriteRect.size.x * $Sprite.scale.x
	
	if $Sprite.texture == null:
		print(self, " no texture available")
		return
	
	$Sprite.global_position.x = -spriteWidth
	spriteFrames.append($Sprite)
	
	
	# Create duplicates of the given sprite.
	for i in range(0, 2):
		var sprite = Sprite.new()
		sprite.texture = $Sprite.texture
		sprite.centered = false
		add_child(sprite)
		sprite.global_position.x = i * spriteWidth
		sprite.global_position.y = global_position.y
		spriteFrames.append(sprite)
		
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for spriteFrame in spriteFrames:
		spriteFrame.translate(speed * delta)
		#print(spriteFrame, spriteFrame.global_position)
		if spriteFrame.global_position.x >= limits.x:
			spriteFrame.global_position.x -= spriteWidth * 3
