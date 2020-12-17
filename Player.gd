extends KinematicBody2D

enum States { 
	IN_AIR, 
	ON_FLOOR,  
	ON_WALL 
}

onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var player = $AudioStreamPlayer2D
onready var colision = $CollisionShape2D

var current_state = States.ON_FLOOR
var second_jump = false
var dash_state = true
var velocity: Vector2 = Vector2.ZERO
var GRAVITY = 200
var MOVE_SPEED = 120 

const JUMP_POWER = 128
const ACCELERATION = 500
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02



func update_state():
	if is_on_floor():
		current_state = States.ON_FLOOR
		second_jump = true
	elif is_on_wall() and !is_on_floor():
		current_state = States.ON_WALL
		second_jump = true
	elif is_on_wall() and is_on_floor():
		current_state = States.ON_WALL
	else:
		current_state = States.IN_AIR
		
		
func _physics_process(delta):
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var seat_state = Input.is_action_pressed("ui_down")
	
	match (current_state):
		States.IN_AIR:
			
			move_character(delta, direction, seat_state)
			jump(delta, direction)
			dash(delta, direction)
			my_crush(delta, seat_state)
			
		States.ON_FLOOR:
			move_character(delta, direction, seat_state)
			jump(delta, direction)
			dash(delta, direction)
			
		States.ON_WALL:
			move_character(delta, direction, seat_state)
			jump(delta, direction)
			dash(delta, direction)
			
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	update_state()


func move_character(delta, direction, seat_state):
	if direction != 0:
		if seat_state:
			animation.play("Seat")
			$Col_Run.disabled = true
			$Col_Seat.disabled = false
			velocity.x = direction  * ACCELERATION * delta * MOVE_SPEED
			velocity.x = clamp(velocity.x , -MOVE_SPEED, MOVE_SPEED)
			sprite.flip_h = velocity.x < 0
		else:
			animation.play("Run")
			$Col_Run.disabled = false
			$Col_Seat.disabled = true
			velocity.x = direction  * ACCELERATION * delta * MOVE_SPEED
			velocity.x = clamp(velocity.x , -MOVE_SPEED, MOVE_SPEED)
			sprite.flip_h = velocity.x < 0
	elif seat_state:
		animation.play("Seat_Stay")
		$Col_Run.disabled = false
		$Col_Seat.disabled = true
	else:
		animation.play("Stay")
		$Col_Run.disabled = false
		$Col_Seat.disabled = true


func jump(delta, direction):
	if current_state == States.ON_FLOOR:
		if direction == 0:
			velocity.x = lerp(velocity.x, 0, FRICTION)
		
		if Input.is_action_just_pressed(("ui_up")):
			animation.play("Jump")
			player.play(0)
			velocity.y = -JUMP_POWER
	else:
		if Input.is_action_just_released(("ui_up")) and velocity.y < -JUMP_POWER/2:
			animation.play("Jump")
			
			velocity.y = -JUMP_POWER/2
		if direction == 0:
			velocity.x = lerp(velocity.x, 0, AIR_RESISTANCE)
			
	if (current_state == States.IN_AIR or current_state == States.ON_WALL) and second_jump == true:
		if Input.is_action_just_pressed(("ui_up")):
			animation.play("Jump")
			player.play(0)
			velocity.y = -JUMP_POWER
			second_jump = false

func dash(delta, direction):
	if dash_state and Input.is_action_just_pressed("ui_dash"):
		MOVE_SPEED = 600
		GRAVITY = 0
		dash_state = false
		$Dash_timer.start()
		$Dash_cd.start()

func _on_Dash_timer_timeout():
	MOVE_SPEED = 120
	GRAVITY = 200


func _on_Dash_cd_timeout():
	if current_state != States.IN_AIR:
		dash_state = true
		
func my_crush(delta, seat_state):
	if current_state == States.IN_AIR and seat_state:
		GRAVITY = 500
		velocity.y += GRAVITY * delta + delta
	GRAVITY = 200
		
	


