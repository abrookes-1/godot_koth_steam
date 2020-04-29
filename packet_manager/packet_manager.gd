extends Node
onready var steam_controller = $"/root/SteamController"

func _ready():
	var player_position = Vector3(1, 2 ,3)
	var packet_dic = {
  "1": {
	"id": 1,
	"name": "Player",
	"position": player_position
  }
}
