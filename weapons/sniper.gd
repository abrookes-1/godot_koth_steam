extends Spatial

const DAMAGE = 15
var bullet_scene = preload("res://weapons/ammo/bullet.tscn")


onready var firepoint = $"Head/camera/firepoint"

func _ready():
	print(name)

func fire_weapon():
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)
	clone.global_transform = self.global_transform
	#var forward_dir = global_transform.basis.z.normalized()
	#var facing = global_transform.basis
#	var facing = get_parent().get_camera_transform().basis
#	facing = -facing.z
#	print(facing)
	#clone.forward_dir = facing
	#scene_root.add_child(clone)
