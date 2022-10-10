extends KinematicBody2D

#HP and Armor related.
##########################################
var health:float = 100
var maxHealth:float = 100

var bodyHitFactors = {
	"head":2,
	"torso":1,
	"legs":0.5,
	"full":2
}
var armorHealth:float = 100
var maxArmorHealth:float = 100

# Invulnerability
var invulnerabilityTimer:Timer
var invulneravilityPeriod:float = 0.2
var isInvulnerable:bool = false
##########################################


# Movement related variables.
###########################################
var velocity:Vector2 = Vector2()
var acceleration:Vector2 = Vector2()

export var gravity:int = 20
export var accelerationMagnitude:int = 50
export var maxVelocity:int = 500

export var jumpAcceleration:int = 600

var constantVelocity = Vector2.ZERO
###########################################
var limits:Vector2 = Vector2()


export var isUnderControl = true
export var AIEnabled = false
var target
var aiConstantVelocity = 20
var aiConstantAcceleration = 20

var spawner = null

export(String, "insas", "pistol", "shotgun", "akm", "ishapore", "m4a1Carbine") var chosenWeapon = "pistol"

# Called when the node enters the scene tree for the first time.
func _ready():
	limits = get_viewport_rect().size
	invulnerabilityTimer = Timer.new()
	
	add_child(invulnerabilityTimer)
	
	invulnerabilityTimer.wait_time = invulneravilityPeriod
	invulnerabilityTimer.one_shot = true
	invulnerabilityTimer.autostart = false
	
	var weaponNode = get_node("Weapon")
	if weaponNode != null:
		weaponNode.setShootingCenter(global_position)
	var _timerErrorCode = invulnerabilityTimer.connect("timeout", self, "stopInvulnerability")
	#print("Player Timer Error code : ", _timerErrorCode)
	$Weapon.underPlayerControl = isUnderControl
	
	if is_instance_valid(target) and !isUnderControl:
		target = get_parent().get_node("Player")
		
	if !isUnderControl and "Enemy" in name:
		connect("tree_exited", spawner, "removeEnemy", [self])
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float):
	if !is_instance_valid(target):
		var parent = get_parent()
		for child in parent.get_children():
			if "Player" in child.name:
				target = child
			
		if target == null:
			return
	# Death check
	if health <= 0:
		if  !isUnderControl:
			queue_free()
			return
			
		deathSequence()
	
	# The following is to make this entire codebase applicable for an enemy instance too.
	if isUnderControl:
		# Basic Input control, use the same following code pattern and map it to a touch controller.
		if Input.is_action_pressed("ui_left"):
			acceleration.x = -accelerationMagnitude
		elif Input.is_action_pressed("ui_right"):
			acceleration.x = accelerationMagnitude
		else:
			acceleration.x = 0
		
		if Input.is_action_pressed("ui_up") and is_on_floor():
			acceleration.y = -jumpAcceleration
		else:
			acceleration.y = 0
	
	# Weapon positioning
	var mousePosition = get_global_mouse_position()
	var positionToFace = mousePosition
	
	if AIEnabled and is_instance_valid(target):
		positionToFace = target.global_position
	
	if positionToFace.x < global_position.x:
		$Weapon.scale = Vector2(-0.4, 0.4)
		$Weapon.position.x = -20
		if not $"Weapon/Melee Slash Animation".is_playing():
			$Weapon.rotation = $Weapon.global_position.angle_to_point(positionToFace)
	else:
		$Weapon.scale = Vector2(0.4, 0.4)
		$Weapon.position.x = 15
		if not $"Weapon/Melee Slash Animation".is_playing():
			$Weapon.rotation = positionToFace.angle_to_point($Weapon.global_position)
	if AIEnabled and is_instance_valid(target):
		#print(target)
		acceleration.x = aiConstantAcceleration * sign(-global_position.x + target.global_position.x)
		$Weapon.target = target
	
	
	
	
	self.velocity.x += self.acceleration.x
	self.velocity.y += self.acceleration.y + self.gravity
	
	self.velocity.x = clamp(self.velocity.x, -maxVelocity, maxVelocity)
	self.velocity.y = clamp(self.velocity.y, -maxVelocity, maxVelocity)
	
	self.velocity.x = lerp(self.velocity.x, 0, 0.12)
	#self.velocity.y = lerp(self.velocity.y, 0, 0.2)

	#Basic Animation Stuff
	if acceleration.x != 0:
		$AnimatedSprite.play("Run")
		if acceleration.x < 0:
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.play("Idle")
	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite.play("Up")
		else:
			$AnimatedSprite.play("Down")
			
	velocity = move_and_slide(velocity, Vector2.UP)

func getVelocityFromTarget():
	var direction = global_position.direction_to(target.global_position)
	print(direction)
	return direction * aiConstantVelocity


func stopInvulnerability():
	isInvulnerable = false
	$"Blood Particles".emitting = false

# Full body hits are not blocked by the armor.
func getHit(damage:float, bodyPart:String, hitter:Node2D):
	if isInvulnerable:
		#print("Won't get hit.")
		return
	if bodyHitFactors.has(bodyPart):
		# Reduced damage if armor has the capability to block.
		if armorHealth >= damage * 0.9:
			armorHealth -= damage * 0.9 * bodyHitFactors[bodyPart]
			health -= damage * 0.1 * bodyHitFactors[bodyPart]
		# If armor is fucked, entire damage goes to the body.
		else:
			health -= damage * bodyHitFactors[bodyPart]
		
		health = clamp(health, 0, maxHealth)
		armorHealth = clamp(armorHealth, 0, maxArmorHealth)
		
		var direction:Vector2 = Vector2()
		
		direction = hitter.global_position.direction_to(global_position)
		if hitter.has_method("nameTagForHackySolutionPleaseEraseMe") and !isUnderControl:
			direction *= -1
		# Make invulnerable for a period to prevent continuos damage.
		isInvulnerable = true
		invulnerabilityTimer.start(invulneravilityPeriod)
		#hitKnockback(direction)
		
		# Stopping blood particle emission using invulnerability
		$"Blood Particles".rotation = direction.angle()
		$"Blood Particles".emitting = true
		
	else:
		print("Unknown body part hit reported : ", bodyPart)
		return
	updateInfoBars()
	#print("Got hit by ", damage, " in ", bodyPart, " by ", hitter)

func deathSequence():
	print("Player is dead.")
	
	var newPlayer:Node2D = load("res://Player/Player.tscn").instance()
	get_parent().add_child(newPlayer)
	newPlayer.global_position = global_position
	newPlayer.global_position.y -= 100
	newPlayer.isUnderControl = true
	#print(newPlayer)
	newPlayer.z_index = self.z_index
	var newCamera:Camera2D = $Camera2D.duplicate()
	newPlayer.add_child(newCamera)
	newCamera.current = true

	var ragdoll:Node2D = load("res://Player/Ragdoll/Ragdoll.tscn").instance()
	get_parent().add_child(ragdoll)
	ragdoll.z_index = z_index
	ragdoll.global_position = global_position
	queue_free()
	
func increaseHealth(healthIncrement:float = 10):
	health = clamp(health + healthIncrement, 0, maxHealth)
	updateInfoBars()

func disableShooting():
	$Weapon.underPlayerControl = false

func enableShooting():
	$Weapon.underPlayerControl = true

func updateInfoBars():
	$"Info Bars".updateArmor()
	$"Info Bars".updateHealth()

func hitKnockback(direction:Vector2):
	self.velocity += direction * 500


func _on_Player_mouse_entered():
	disableShooting()
	print('BOOOOOOOOOOOOOOOOoo')


func _on_Player_mouse_exited():
	enableShooting()
