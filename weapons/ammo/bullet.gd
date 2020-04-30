extends KinematicBody

var BULLET_SPEED = 20
var BULLET_DAMAGE = 15
const KILL_TIMER = 6
var timer = 0
var hit_something = false
#var forward_dir
var velocity = Vector3()
var gravity = -9.8

func _ready():
	velocity = -transform.basis.z * BULLET_SPEED

func _physics_process(delta):
	timer += delta
	if timer >= KILL_TIMER:
		queue_free()
	
	
	# velocity.y += gravity
	
	
	var collision = move_and_collide(velocity * delta)
	
#	if collision:
#		var collided_with = collision.collider as StaticBody
#
#		if collided_with.is_in_group('shootable'):
#			print('ded')

func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)

	hit_something = true
	queue_free()
