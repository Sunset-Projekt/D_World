extends KinematicBody2D

enum States{
	WAIT,
	FOLLOWING,
}

var current_state = States.WAIT

var velocity = Vector2()
var GRAVITY = 200
var MOVE_SPEED = 100
const ACCELERATION = 25

onready var animation = $AnimationPlayer
onready var player = get_node(("/root/World/Player/"))

func create_direction():
	if player.position.x - position.x < 0:
		return -1
	else:
		return 1
	return 0

func update_state():
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

func _on_Area2D_body_entered(body: KinematicBody2D):
	pass
