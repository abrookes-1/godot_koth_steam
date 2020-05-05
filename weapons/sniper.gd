extends Spatial

const DAMAGE = 15


onready var firepoint = $"Firepoint"
onready var network_manager = $"/root/NetworkManager"
onready var game_state = $"/root/GameStateManager"
onready var player = $'../../../'
onready var bullet = "res://weapons/ammo/bullet.tscn"

func _ready():
	pass

func fire_weapon():
	if player.is_owner:
		network_manager.spawn_new_networked('bullet', firepoint.global_transform)
		game_state.add_bullet_count()
