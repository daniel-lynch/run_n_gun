extends KinematicBody2D

var dying : bool
var Target : KinematicBody2D

var LookDir : int = 0
var SeeDistance : int = 5 * 64
var health : int = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	LookDir = -1 if $AnimatedSprite.flip_h else 1

	if dying:
		return

	$Line2D.set_point_position(1, (Vector2(LookDir * SeeDistance / 2,0)))

	var space_state = get_world_2d().direct_space_state
	var Ray = space_state.intersect_ray(self.position, (Vector2(LookDir,0) * SeeDistance) + self.position, [self], collision_mask)
	if Ray:
		if Ray.collider.name == "Player":
			Target = Ray.collider
	if Target:
		shoot()


func shoot():
	$AnimatedSprite.play("Shooting")


func hit():
	health -= 5
	if health <= 0:
		die()
		
func die():
	dying = true
	$CollisionShape2D.disabled = true
	$AnimatedSprite.play("Die")


func _on_AnimatedSprite_animation_finished():
	pass
	#if $AnimatedSprite.animation == "Die":
	#	yield(get_tree().create_timer(5.0), "timeout")
	#	queue_free()
