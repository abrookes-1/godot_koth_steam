extends KinematicBody

var camera_angle = 0
var mouse_sensitivity = 0.1

var velocity = Vector3()
var direction = Vector3()

const FLY_SPEED = 40
const FLY_ACCEL = 4

var gravity = -9.8 * 3
const MAX_SPEED = 20
const MAX_RUNNING_SPEED = 30
const ACCEL = 2
const DECEL = 6
var jump_height = 15
var temp = 0

var spawn_params # set on spawn, do stuff with it in ready
var net_id
var steam_id
var steam_name
var is_owner
var has_contact = false
const MAX_SLOPE_ANGLE = 35

onready var network_manager = $"/root/NetworkManager"
onready var steam_controller = $"/root/SteamController"

func _ready():
	print("new player ready: " + str(net_id))
	steam_id = spawn_params['steam_id']
	steam_name = spawn_params['steam_name']
	is_owner = steam_id == steam_controller.STEAM_ID
	if is_owner:
		get_node('Head/Camera').make_current()

func _process(delta):
	if is_owner:
		_walk(delta)
		
	_do_gravity(delta)


func _physics_process(delta):
	#if network_manager.is_host:
	if is_owner:
		network_manager.send_position(self)


func _input(event):
	if event is InputEventMouseMotion:
		$Head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change


func _walk(delta):
	direction = Vector3()
	var facing = $Head/Camera.get_camera_transform().basis
	
	if Input.is_action_pressed("move_fw"):
		direction -= facing.z
	if Input.is_action_pressed("move_bw"):
		direction += facing.z
	if Input.is_action_pressed("move_l"):
		direction -= facing.x
	if Input.is_action_pressed("move_r"):
		direction += facing.x

	direction = direction.normalized()
	
	if (is_on_floor()):
		has_contact = true
	else:
		if !$'FeetCast'.is_colliding():
			has_contact = false
	
	if (has_contact and !is_on_floor()):
		move_and_collide(Vector3(0,-0.1,0))
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	if Input.is_action_pressed("move_sprint"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	var target = direction * speed
	
	# determine if accelerating or decelerating
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DECEL
	
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z

	if has_contact and Input.is_action_just_pressed("move_jump"):
		velocity.y = jump_height
		has_contact = false

	velocity = move_and_slide(velocity, Vector3(0,1,0))



func _do_gravity(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
	else:
		var n = $'FeetCast'.get_collision_normal()
		var floor_angle = rad2deg(acos(n.dot(Vector3.UP)))
		if floor_angle > MAX_SLOPE_ANGLE:
			velocity.y += gravity * delta


func _fly(delta):
	direction = Vector3()
	var facing = $Head/Camera.get_camera_transform().basis
	
	if Input.is_action_pressed("move_fw"):
		direction -= facing.z
	if Input.is_action_pressed("move_bw"):
		direction += facing.z
	if Input.is_action_pressed("move_l"):
		direction -= facing.x
	if Input.is_action_pressed("move_r"):
		direction += facing.x

	direction = direction.normalized()
	var target = direction * FLY_SPEED
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta)
	
	move_and_slide(velocity)

func set_pos(vec):
	self.translation = vec

func set_rotation(q):
	self.transform.basis = q
