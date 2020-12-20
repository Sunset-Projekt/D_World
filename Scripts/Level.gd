extends Node


func get_player():
	if has_node("Player"):
		return $Player
	else:
		return false 
	



func _ready():
	pass # Replace with function body.


