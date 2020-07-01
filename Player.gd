extends KinematicBody2D


var MoveSpeed : int = 350
var JumpForce :int = 850
var Gravity : int = 50
var MaxFallSpeed : int = 1000

var Health : int = 50

var Dying : bool
var Moving : bool = false
var Crouching : bool = false
var Shooting : bool = false
var Jumping : bool = false
var grounded : bool
var CanShoot : bool = true
var CanCrouch : bool = true
var ShootingAlt : bool = false
var dir : int = 0
var timer : Timer

var Bullet = preload("res://Bullet.tscn")

onready var sprite = $Sprite

var YVel = 0

func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(.15)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)

func on_timeout_complete():
	CanShoot = true

func _physics_process(delta):
	if Dying:
		YVel += Gravity
		move_and_slide(Vector2(0, YVel), Vector2(0, -1))
		var grounded = is_on_floor()
		if grounded and YVel >= 5:
			YVel = 5
		if YVel > MaxFallSpeed:
			YVel = MaxFallSpeed
		return

	var MoveDir = 0
	if Input.is_action_pressed("move_right"):
		MoveDir += 1
	if Input.is_action_pressed("move_left"):
		MoveDir -= 1
		
	if MoveDir == 1:
		$AnimatedSprite.flip_h = false
	if MoveDir == -1:
		$AnimatedSprite.flip_h = true
		

	if $AnimatedSprite.flip_h:
		$Muzzle.position = Vector2(-27,7)
		dir = -1
	else:
		$Muzzle.position = Vector2(27,7)
		dir = 0

	if MoveDir != 0:
		Crouching = false
		Moving = true
		if !Jumping:
			if Shooting && !ShootingAlt:
				$AnimatedSprite.play("Shoot_Running")
			if ShootingAlt:
				$AnimatedSprite.play("Shoot_Running_Up")
			if !Shooting && !ShootingAlt:
				$AnimatedSprite.play("Running")
	if MoveDir == 0:
		if !Jumping:
			if Shooting && !Crouching && !ShootingAlt:
				$AnimatedSprite.play("Shoot_Idle")
			if !Shooting && Crouching && !ShootingAlt:
				$AnimatedSprite.play("Crouch")
			if Shooting && Crouching && !ShootingAlt:
				if $AnimatedSprite.flip_h:
					$Muzzle.position = Vector2(-27,18)
				else:
					$Muzzle.position = Vector2(27,18)
				$AnimatedSprite.play("Shoot_Crouch")
			if ShootingAlt && !Crouching:
				$AnimatedSprite.play("Shoot_Idle_Up")
			if !Shooting && !Crouching && !ShootingAlt:
				$AnimatedSprite.play("Idle")

		
	if Input.is_action_pressed("shoot"):
		Shooting = true
		ShootingAlt = false
	if Input.is_action_just_released("shoot"):
		Shooting = false
	if Input.is_action_pressed("shoot_alt"):
		Shooting = false
		CanCrouch = false
		ShootingAlt = true
		if !Crouching:
			$Muzzle.position = Vector2(1,-27)
			dir = 3
	if Input.is_action_just_released("shoot_alt"):
		CanCrouch = true
		ShootingAlt = false
		if $AnimatedSprite.flip_h:
			dir = -1
			$Muzzle.position = Vector2(-27,7)
		else:
			dir = 0
			$Muzzle.position = Vector2(27,7)
	if Input.is_action_pressed("crouch"):
		if CanCrouch:
			Crouching = true
		if !ShootingAlt:
			if $AnimatedSprite.flip_h:
				$Muzzle.position = Vector2(-27,18)
			else:
				$Muzzle.position = Vector2(27,18)
	if Input.is_action_just_released("crouch"):
		if Crouching:
			Crouching = false
			if $AnimatedSprite.flip_h:
				$Muzzle.position = Vector2(-27,7)
			else:
				$Muzzle.position = Vector2(27,7)
			
	grounded = false
	var space_state = get_world_2d().direct_space_state
	for x in range(-14,20):
		var Ray = space_state.intersect_ray(self.position, Vector2(x,48) + self.position, [self], collision_mask)
		if Ray:
			grounded = true


	var XVel = MoveDir * MoveSpeed
	YVel += Gravity
	if grounded:
		if Input.is_action_pressed("jump"):
			YVel = -JumpForce
			Jumping = true
		else:
			if Jumping:
				$AnimatedSprite.play("Idle")
			Jumping = false

	if grounded and YVel >= 5:
		YVel = 5
	if YVel > MaxFallSpeed:
		YVel = MaxFallSpeed

	if CanShoot:
		if Shooting || ShootingAlt:
			shoot()
			CanShoot = false
			timer.start()
	move_and_slide(Vector2(XVel, YVel), Vector2(0, -1))


func hit():
	Health -= 5
	if Health <= 0:
		die()
		
func die():
	Dying = true
	#$CollisionShape2D.disabled = true
	$AnimatedSprite.play("Die")


func shoot():

	var b = Bullet.instance()
	b.start($Muzzle.global_position, dir, self)
	get_parent().add_child(b)
