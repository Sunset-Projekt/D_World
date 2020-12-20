extends KinematicBody2D


onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var health_points = 50


export var max_health_points = 100


var GRAVITY = 200


func _ready():
	set_start_hp(health_points, max_health_points)


func set_start_hp(health_points, max_health_points):
	$HP_Bar.value = health_points
	$HP_Bar.max_value = max_health_points


func update_hp():
	$HP_Bar.value = health_points


func die():
	get_parent().remove_child(self)
	queue_free()


func reduce_hp(val):
	self.health_points -= val
	update_hp()
	if self.health_points <=0:
		die()
