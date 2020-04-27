extends Spatial

func _ready():
	var INIT = Steam.steamInit()
#
	if INIT['status'] != 1:
    	print("Failed to initialize Steam. "+str(INIT['verbal'])+" Shutting down...")
    	get_tree().quit()

	print(str(INIT))
#	print(Steam.getSteamID())
	
	print(INIT['verbal'])
	print("done")