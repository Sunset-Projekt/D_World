extends "res://Scripts/ADAM.gd"
enum States{
	WAIT,
	FOLLOWING,
}


onready var player = get_node("/root/World/Level/Player")


var current_state = States.WAIT
var velocity = Vector2()
var MOVE_SPEED = 100
var target_intercepted = false
var can_attack = true
var attack_strength = 50

const ACCELERATION = 25


func _ready():
	add_to_group(GlobalVars.entity_group)
	add_to_group(GlobalVars.enemy_group)
	self.health_points = 45
	self.max_health_points = 60
	set_start_hp(self.health_points, self.max_health_points)


func create_direction():
	if player.position.x - position.x < 0:
		return -1
	else:
		return 1
	return 0

func update_state():
	if has_node("/root/World/Level/Player"):
		if abs(player.position.x - position.x) < 80:
				current_state = States.FOLLOWING
	else:
		current_state = States.WAIT
		
func _physics_process(delta):
	match(current_state):
		States.WAIT:
			wait()
		States.FOLLOWING:
			follow(delta)
	
	
	if target_intercepted and can_attack:
		attack(player)
	
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	update_state()

func follow(delta):
	if(current_state == States.FOLLOWING):
		animation.play("Run")
		velocity.x = create_direction()  * ACCELERATION * delta * MOVE_SPEED
		velocity.x = clamp(velocity.x , -MOVE_SPEED, MOVE_SPEED)

func wait():
	if(current_state == States.WAIT):
		velocity.x = 0


func attack(player):
	player.reduce_hp(attack_strength)
	can_attack = false
	$Attack_Cooldown.start()
	


func _on_Attack_Cooldown_timeout():
	can_attack = true


func _on_Attackbox_area_entered(area):
	if area.get_parent() == player:
		target_intercepted = true


func _on_Attackbox_area_exited(area):
	if area.get_parent() == player:
		target_intercepted = false
