extends NinePatchRect

func _on_interface_money_changed(count):
	var money = 0
	money += 1
	$Number.text = str(money)
