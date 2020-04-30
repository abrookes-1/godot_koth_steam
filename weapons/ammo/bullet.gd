extends KinematicBody

var BULLET_SPEED = 100
var BULLET_DAMAGE = 15
const KILL_TIMER = 6
var timer = 0
var hit_something = false

# physics
var velocity = Vector3()
var gravity = -9.8 * 0.01

# needed to make networked
var spawn_params
var net_id

onready var network_manager = $"/root/NetworkManager"

func _ready():
	velocity = -transform.basis.z * BULLET_SPEED

func _physics_process(delta):
	timer += delta
	if timer >= KILL_TIMER:
		queue_free()
	
	velocity.y += gravity
	
	var collision = move_and_collide(velocity * delta)
	
#	if collision:
#		velocity = Vector3.ZERO
#		var collided_with = collision.collider as StaticBody
#
#		if collided_with.is_in_group('shootable'):
#			print('ded')
	
	if network_manager.is_host:
		pass
		# detect and report collision
	
	
func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)

	hit_something = true
	queue_free()
