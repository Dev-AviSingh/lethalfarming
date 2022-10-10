extends Node2D


# When called fire, choose the appropriate function for that mode
var firingModes = {
	"automatic": "autoFire",
	"burst": "burstFire",
	"single": "singleFire",
	"projectile": "projectileFire",
	"shotgun": "shotgunFire",
	"melee": "meleeFire"
}

################################################################################
#WEAPON CONFIGURATIONS
var pistol = {
	firingMode = "single",
	bulletDamage = 5,
	meleeDamage = 1,
	bulletSpeed = 500,
	firingInterval= .9,
	imageLocation = "res://Weapons/Weapon Sprites/Pistol.png"
}
var shotgun = {
	firingMode = "shotgun",
	bulletDamage = 10,
	meleeDamage = 5,
	bulletSpeed = 900,
	firingInterval= .5,
	imageLocation = "res://Weapons/Weapon Sprites/Shotgun.png"
}
var rocketLauncher = {
	firingMode = "projectile",
	bulletDamage = 200,
	meleeDamage = 0,
	bulletSpeed = 400,
	firingInterval= 2,
	imageLocation = ""
}
var grenadeLauncher = {
	firingMode = "projectile",
	bulletDamage = 100,
	meleeDamage = 0,
	bulletSpeed = 300,
	firingInterval= 1.5,
	imageLocation = ""
}
var m4a1Carbine = {
	firingMode = "single",
	bulletDamage = 20,
	meleeDamage = 1,
	bulletSpeed = 800,
	firingInterval= .05,
	imageLocation = "res://Weapons/Weapon Sprites/M4A1 Carbine.png"
}
var akm = {
	firingMode = "single",
	bulletDamage = 30,
	meleeDamage = 1,
	bulletSpeed = 800,
	firingInterval= .2,
	imageLocation = "res://Weapons/Weapon Sprites/akm 2.png"
}
var ishapore = {
	firingMode = "single",
	bulletDamage = 150,
	meleeDamage = 10,
	bulletSpeed = 1000,
	firingInterval= .8,
	imageLocation = "res://Weapons/Weapon Sprites/Ishapore Sniper Rifle.png"
}
var insas = {
	firingMode = "single",
	bulletDamage = 25,
	meleeDamage = 1,
	bulletSpeed = 850,
	firingInterval= .175,
	imageLocation = "res://Weapons/Weapon Sprites/Insas.png"
}
################################################################################

################################################################################
# Weapon config variables.
var firingFunction:String = firingModes["shotgun"]
var spriteLocation:String
var bulletResourceLocation:String = "res://Weapons/Bullet.tscn"
var bulletDamage:int = 10
var meleeDamage:int = 2
var bulletSpeed:int = 700
################################################################################
var bulletsShot:int = 0

var knockbackTimer:Timer
var firingIntervalTimer:Timer
var burstFiringIntervalTimer:Timer
var meleeAnimationTimer:Timer

var firingInterval:float = .2 # in seconds
var burstInterval:float = .1
var meleeAnimationInterval:float = .1
var meleeAnimationTargetAngle:float = 0

var burstCount:int = 3
var burstShotIndex = 0

var allowFiring:bool = true
var keepAutoFiring:bool = false

var bulletTemplate:Resource

var directionVector:Vector2

var underPlayerControl = true
var target:Node2D

var fixedHeight:float = 40
var fixedWidth:float = 130

var weapons = {
	"insas": insas,
	"pistol": pistol,
	"shotgun": shotgun,
	"akm": akm,
	"ishapore": ishapore,
	"m4a1Carbine": m4a1Carbine
}
#var weaponConfig = weapons[floor(rand_range(0, weapons.size()))]
var weaponConfig = null
# Called when the node enters the scene tree for the first time.
func _ready():
	weaponConfig = get_parent().chosenWeapon
	if weaponConfig == null or weaponConfig == "":
		weaponConfig = weapons["ishapore"]
		#print("weaponConfig is empty")
	else:
		weaponConfig = weapons[weaponConfig]
	firingFunction = firingModes[weaponConfig["firingMode"]]
	bulletDamage = weaponConfig["bulletDamage"]
	meleeDamage = weaponConfig["meleeDamage"]
	bulletSpeed = weaponConfig["bulletSpeed"]
	firingInterval = weaponConfig["firingInterval"]
	spriteLocation = weaponConfig["imageLocation"]
	bulletTemplate = load(bulletResourceLocation)
	
	$Sprite.texture = load(spriteLocation)
	
	#print(fixedWidth, " / ", $Sprite.texture.get_width(), " = ", fixedWidth/$Sprite.texture.get_width())
	$Sprite.scale.x = fixedWidth/$Sprite.texture.get_width()
	$Sprite.scale.y = fixedHeight/$Sprite.texture.get_height()
	#print($Sprite.scale)
	firingIntervalTimer = Timer.new()
	firingIntervalTimer.wait_time = firingInterval
	firingIntervalTimer.one_shot = true
	firingIntervalTimer.connect("timeout", self, "enableFiring")
	add_child(firingIntervalTimer)
	
	burstFiringIntervalTimer = Timer.new()
	burstFiringIntervalTimer.connect("timeout", self, "burstFire")
	burstFiringIntervalTimer.one_shot = true
	add_child(burstFiringIntervalTimer)
	
	meleeAnimationTimer = Timer.new()
	meleeAnimationTimer.wait_time = meleeAnimationInterval
	meleeAnimationTimer.one_shot = true
	meleeAnimationTimer.connect("timeout", self, "meleeAnimation")
	add_child(meleeAnimationTimer)
	$"Melee Slash Animation".connect("animation_finished", self, "stopSlashAnimation")
	

func enableFiring():
	allowFiring = true


func knockback():
	pass


func fire():
	if allowFiring:
		call(firingFunction)
		#print("Bullets shot : ", bulletsShot)
		allowFiring = false
		firingIntervalTimer.start(firingInterval)


func autoFire(start = null):
	if start != null:
		keepAutoFiring = start
	else:
		keepAutoFiring = not keepAutoFiring
		print(keepAutoFiring)


func burstFire():
	if burstShotIndex == burstCount:
		burstShotIndex = 0
		return
	
	burstShotIndex += 1
	burstFiringIntervalTimer.start(burstInterval)
	singleFire()
	#print(burstShotIndex)


func singleFire(relativeRotation:float = 0):
	var bullet:Area2D = bulletTemplate.instance()
	get_tree().root.add_child(bullet)
	bullet.global_position = $"Bullet Flash".global_position
	bullet.velocity = directionVector * bulletSpeed
	bullet.rotation = self.rotation
	bullet.velocity = bullet.velocity.rotated(relativeRotation)
	bulletsShot += 1
	
	if !underPlayerControl:
		bullet.set_collision_mask_bit(0, 1)
		bullet.set_collision_mask_bit(1, 0)

func shotgunFire():
	for x in range(-2, 3):
		var angleDifference = deg2rad(10) * x
		singleFire(angleDifference)

func projectileFire():
	pass


func meleeAnimation():
	#rotation = lerp_angle(rotation, meleeAnimationTargetAngle, 0.12)
	rotation = clamp(rotation + rad2deg(1), rotation, meleeAnimationTargetAngle)
	if $"Melee Slash Animation".is_playing():
		meleeAnimationTimer.start(meleeAnimationInterval)
	print(rad2deg(rotation))

func meleeFire():
	var collisions = $"Melee Hit Area".get_overlapping_bodies()
	for collider in collisions:
		if collider is KinematicBody2D:
			if allowFiring:
				if collider.has_method("getHit"):
					collider.getHit(meleeDamage, "torso", self)
				allowFiring = false
				firingIntervalTimer.start(firingInterval)
	
#	meleeAnimationTargetAngle = rotation + deg2rad(50)
#	rotation -= deg2rad(50)
	$"Melee Slash Animation".play("slash")
	#meleeAnimation()

func stopSlashAnimation():
	$"Melee Slash Animation".stop()

func setShootingCenter(pos:Vector2):
	$"Shooting Center".global_position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# This gets toggled by the firing function for automatic.
#	if keepAutoFiring:
#		if allowFiring:
#			singleFire()
#			allowFiring = false
#			firingIntervalTimer.start(firingInterval)
	
	if underPlayerControl:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			var mousePosition = get_global_mouse_position()
			directionVector = $"Shooting Center".global_position.direction_to(mousePosition).normalized()
	
			fire()
			#print(keepAutoFiring)
	else:
		if is_instance_valid(target):
			directionVector = $"Shooting Center".global_position.direction_to(target.global_position).normalized()
			fire()
