extends KinematicBody2D

var hvelocity : int
var vvelocity : int
var velocity : Vector2

var shooter


func start(pos, dir, from):
	shooter = from
	rotation = 0
	position = pos
	match dir:
		-1:
			hvelocity = -1000
			vvelocity = 0
		0:
			hvelocity = 1000
			vvelocity = 0
		3:
			hvelocity = 0
			vvelocity = -1000
		4:
			hvelocity = 0
			vvelocity = 1000

	velocity = Vector2(hvelocity, vvelocity).rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		#velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("hit") && collision.collider.name != shooter.name:
			collision.collider.hit()
			queue_free()
		else:
			if collision.collider.name != shooter.name:
				queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
