extends KinematicBody


var camera_angle = 0
var mouse_sensitivity = 0.1

var velocity = Vector3()
var direction = Vector3()

const FLY_SPEED = 40
const FLY_ACCEL = 4

var gravity = -9.8 * 3
const MAX_SPEED = 15
const MAX_RUNNING_SPEED = 20
const ACCEL = 2
const DECEL = 20
const AIR_ACCEL = 1
var jump_height = 15
var temp = 0

var timer = 0
var current_money = 0

var spawn_params # set on spawn, do stuff with it in ready
var net_id
var steam_id
var steam_name
var is_owner
var has_contact = false

const MAX_SLOPE_ANGLE = 35

onready var network_manager = $"/root/NetworkManager"
onready var steam_controller = $"/root/SteamController"
onready var weapon = $"Head/Camera/Sniper"
onready var player_mesh = $"Head/Camera/PlayerMainMesh"
onready var player_cam = $'Head/Camera'

func _ready():
#	print("new player ready: " + str(net_id))
	steam_id = spawn_params['steam_id']
	steam_name = spawn_params['steam_name']
	is_owner = steam_id == steam_controller.STEAM_ID
	
	# settings for user's player model
	if is_owner:
		player_cam.make_current()
		player_mesh.set_visible(false)

func _process(delta):
	if is_owner:
		_walk(delta)
	_do_gravity(delta)

func _physics_process(delta):
	# send position with the frequency of _physics_process
	if is_owner:
		network_manager.send_position(self)
		#attempt to send game state info less often then delta
		timer += delta
		if timer > .02:
			network_manager.send_game_state(self)
			current_money += 1
			timer = 0

func _input(event):
	#accepts mouse movment and turns the camera respectivly
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		#limits camera up and down movemnt per 90 degree angle
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
			
	if event is InputEventMouseButton:
		if event.is_action_pressed("shoot"):
			weapon.fire_weapon()

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
	if !has_contact:
		acceleration = AIR_ACCEL
	elif direction.dot(temp_velocity) > 0:
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
	if !is_on_floor_or_slope():
			velocity.y += gravity * delta

func is_on_floor_or_slope():
	if !is_on_floor():
		return false
	else:
		var n = $'FeetCast'.get_collision_normal()
		var floor_angle = rad2deg(acos(n.dot(Vector3.UP)))
		if floor_angle > MAX_SLOPE_ANGLE:
			return false
	return true

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

func get_pos():
	return translation

func set_pos(vec):
	translation = vec

func set_rotation(q):
	$'Head/Camera'.global_transform.basis = Basis(q)

func get_rotation():
	return Quat($'Head/Camera'.global_transform.basis)

func generate_game_state():
	#generates a json of the current state of the game in the cleints eyes
	pass


