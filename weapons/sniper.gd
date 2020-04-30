extends Spatial

const DAMAGE = 15
var bullet_scene = preload("res://weapons/ammo/bullet.tscn")

onready var firepoint = $"Firepoint"

func _ready():
	pass

func fire_weapon():
	var clone = bullet_scene.instance()
	clone.global_transform = firepoint.global_transform
	#clone.forward_dir = -firepoint.global_transform.basis.z.normalized()
	get_tree().get_root().add_child(clone)
