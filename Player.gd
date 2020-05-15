extends KinematicBody2D


var MoveSpeed : int = 350
var JumpForce :int = 850
var Gravity : int = 50
var MaxFallSpeed : int = 1000

var Moving : bool = false
var Crouching : bool = false
var Shooting : bool = false
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
	var MoveDir = 0
	if Input.is_action_pressed("move_right"):
		MoveDir += 1
		dir = 0
	if Input.is_action_pressed("move_left"):
		MoveDir -= 1
		dir = -1
		
	if MoveDir == 1:
		$AnimatedSprite.flip_h = false
		$Muzzle.position = Vector2(26,7)
	if MoveDir == -1:
		$AnimatedSprite.flip_h = true
		$Muzzle.position = Vector2(-26,7)
	if MoveDir != 0:
		Crouching = false
		Moving = true
		if Shooting && !ShootingAlt:
			$AnimatedSprite.play("Shoot_Running")
		if ShootingAlt:
			$AnimatedSprite.play("Shoot_Running_Up")
		if !Shooting && !ShootingAlt:
			$AnimatedSprite.play("Running")
	if MoveDir == 0:
		if Shooting && !Crouching && !ShootingAlt:
			$AnimatedSprite.play("Shoot_Idle")
		if !Shooting && Crouching && !ShootingAlt:
			$AnimatedSprite.play("Crouch")
		if Shooting && Crouching && !ShootingAlt:
			if $AnimatedSprite.flip_h:
				$Muzzle.position = Vector2(-26,18)
			else:
				$Muzzle.position = Vector2(26,18)
			$AnimatedSprite.play("Shoot_Crouch")
		if ShootingAlt && !Crouching:
			$AnimatedSprite.play("Shoot_Idle_Up")
		if !Shooting && !Crouching && !ShootingAlt:
			$AnimatedSprite.play("Idle")
			
	if Shooting && CanShoot:
		shoot()
		CanShoot = false
		timer.start()
		
	if ShootingAlt && CanShoot && !Crouching:
		$Muzzle.position = Vector2(1,-26)
		dir = 3
		shoot()
		CanShoot = false
		timer.start()
		
	if Input.is_action_pressed("shoot"):
		Shooting = true
	if Input.is_action_just_released("shoot"):
		Shooting = false
	if Input.is_action_just_pressed("shoot_alt"):
		CanCrouch = false
		ShootingAlt = true
	if Input.is_action_just_released("shoot_alt"):
		CanCrouch = true
		ShootingAlt = false
		if $AnimatedSprite.flip_h:
			$Muzzle.position = Vector2(-26,7)
			dir = -1
		else:
			$Muzzle.position = Vector2(26,7)
			dir = 0
	if Input.is_action_just_pressed("crouch"):
		if CanCrouch:
			Crouching = true
	if Input.is_action_just_released("crouch"):
		if Crouching:
			Crouching = false
			if $AnimatedSprite.flip_h:
				$Muzzle.position = Vector2(-26,7)
			else:
				$Muzzle.position = Vector2(26,7)
	var space_state = get_world_2d().direct_space_state
	var rresult = space_state.intersect_ray(self.position, (Vector2(1,0) * 21) + self.position, [self], collision_mask)
	var lresult = space_state.intersect_ray(self.position, (Vector2(-1,0) * 20) + self.position, [self], collision_mask)
	var grounded = is_on_floor()
	var XVel = MoveDir * MoveSpeed
	YVel += Gravity
	if grounded and Input.is_action_just_pressed("jump"):
		YVel = -JumpForce
	if rresult:
		if Input.is_action_just_pressed("jump") && rresult.collider: 
			YVel = -JumpForce
			XVel = -JumpForce
	if lresult:
		if Input.is_action_just_pressed("jump") && lresult.collider: 
			YVel = -JumpForce
			XVel = JumpForce
	move_and_slide(Vector2(XVel, YVel), Vector2(0, -1))
	if grounded and YVel >= 5:
		YVel = 5
	if YVel > MaxFallSpeed:
		YVel = MaxFallSpeed





func shoot():

	var b = Bullet.instance()
	b.start($Muzzle.global_position, dir)
	get_parent().add_child(b)
