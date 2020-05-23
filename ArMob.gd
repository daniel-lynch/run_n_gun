extends KinematicBody2D

var Dying : bool
var Alert : bool = false
var GoingAlert : bool = false
var CanShoot : bool = true
var timer : Timer
var AlertTimer : Timer
var Target : KinematicBody2D

var LookDir : int = 0
var SeeDistance : int = 6 * 64
var health : int = 10

var Bullet = preload("res://Bullet.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(.2)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	AlertTimer = Timer.new()
	AlertTimer.set_one_shot(true)
	AlertTimer.set_wait_time(3)
	AlertTimer.connect("timeout", self, "on_Alert_Timeout")
	add_child(AlertTimer)

func on_timeout_complete():
	CanShoot = true

func on_Alert_Timeout():
	Alert = false
	$Exclamation.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	LookDir = -1 if $AnimatedSprite.flip_h else 1

	if Dying:
		return

	$Line2D.set_point_position(1, (Vector2(LookDir * SeeDistance / 2,0.5)))

	var space_state = get_world_2d().direct_space_state
	var Ray = space_state.intersect_ray(self.position, (Vector2(LookDir,0) * SeeDistance) + self.position, [self], collision_mask)
	if Ray:
		if Ray.collider.name == "Player":
			Target = Ray.collider
		else:
			Target = null
	else:
		Target = null
	if Target && !Alert && !GoingAlert:
		alert()
	if Target && Alert:
		shoot()
	if !Target:
		if Alert:
			$AnimatedSprite.play("Alert")
		if Alert && !GoingAlert && AlertTimer.is_stopped():
			AlertTimer.start()
		if !GoingAlert && AlertTimer.is_stopped():
			$AnimatedSprite.play("Idle")

func alert():
	GoingAlert = true
	$AnimatedSprite.play("Alert")
	$Exclamation.visible = true
	yield(get_tree().create_timer(0.3), "timeout")
	Alert = true
	GoingAlert = false

func shoot():
	$AnimatedSprite.play("Shooting")
	if !CanShoot:
		return
	var b = Bullet.instance()
	b.start($Muzzle.global_position, LookDir, self)
	get_parent().add_child(b)
	CanShoot = false
	timer.start()


func hit():
	health -= 5
	if health <= 0:
		die()
		
func die():
	Dying = true
	$Line2D.visible = false
	$Exclamation.visible = false
	$CollisionShape2D.disabled = true
	$AnimatedSprite.play("Die")


func _on_AnimatedSprite_animation_finished():
	pass
	#if $AnimatedSprite.animation == "Die":
	#	yield(get_tree().create_timer(5.0), "timeout")
	#	queue_free()
