extends KinematicBody2D

var Dying : bool
var Alert : bool = false
var CanShoot : bool = true
var timer : Timer
var Target : KinematicBody2D

var LookDir : int = 0
var SeeDistance : int = 5 * 64
var health : int = 10

var Bullet = preload("res://Bullet.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(.2)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)

func on_timeout_complete():
	CanShoot = true

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
	if Target:
		shoot()
	if !Target:
		$AnimatedSprite.play("Idle")

func alert():
	yield(get_tree().create_timer(1.0), "timeout")
	Alert = true

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
	$CollisionShape2D.disabled = true
	$AnimatedSprite.play("Die")


func _on_AnimatedSprite_animation_finished():
	pass
	#if $AnimatedSprite.animation == "Die":
	#	yield(get_tree().create_timer(5.0), "timeout")
	#	queue_free()
