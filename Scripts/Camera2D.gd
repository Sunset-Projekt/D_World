extends Camera2D

onready var player = get_node(("/root/World/Level/Player"))

func _process (_delta):
	if has_node("/root/World/Level/Player"):
		position.x = player.position.x
		position.y = player.position.y - 32
	else:
		position.x = 0
		position.y = 0
