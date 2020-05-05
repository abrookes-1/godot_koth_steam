extends KinematicBody

var BULLET_SPEED = 60
var BULLET_DAMAGE = 15
const KILL_TIMER = 6
const STUCK_KILL_TIMER = 10
var timer = 0
var stuck_timer = 0
var hit_something = false
var stuck = false


# physics
var velocity = Vector3()
var gravity = -9.8 * 0.04

# needed to make networked
var spawn_params
var net_id

onready var network_manager = $"/root/NetworkManager"
onready var game_state = $"/root/GameStateManager"
onready var bullet = "res://weapons/sniper.gd"

func _ready():

	velocity = -transform.basis.z * BULLET_SPEED
#	if game_state.get_bullet_count() > 19:
#		kill_bullet()

func _physics_process(delta):
	timer += delta
	if timer >= KILL_TIMER and !stuck:
		kill_bullet()
	if !stuck:
		stuckreeeeeeeeeeee(delta)
	else:
		stuck_timer += delta
		if stuck_timer >= STUCK_KILL_TIMER:
			kill_bullet()

func stuckreeeeeeeeeeee(delta):
	
	velocity.y += gravity
	
	var collision = move_and_collide(velocity * delta)

	if collision:
		stuck = true
#		print(game_state.get_bullet_id())

func kill_bullet():
	queue_free()
