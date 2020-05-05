extends Node
var bullet_script = preload("res://weapons/ammo/bullet.gd")

var bullet_id = 0 
var money_counter = 0
var player_height
var cash_flow
var bullet_count = 0

func _ready():
	pass

func _process(delta):
	pass

func _get_money(player_height):
	pass

func get_bullet_count():
	print(bullet_count)
	return bullet_count

func add_bullet_count():
	bullet_count += 1
	if bullet_count > 21:
		bullet_count = 20

func get_bullet_id():
	bullet_id += 1
	return bullet_id
