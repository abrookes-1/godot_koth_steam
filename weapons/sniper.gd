extends Spatial

const DAMAGE = 15

onready var firepoint = $"Firepoint"
onready var network_manager = $"/root/NetworkManager"
onready var player = $'../../../'

func _ready():
	pass

func fire_weapon():
#	var clone = bullet_scene.instance()
#	clone.global_transform = firepoint.global_transform
	#get_tree().get_root().add_child(clone)
	if player.is_owner:
		network_manager.spawn_new_networked('bullet', firepoint.global_transform)
