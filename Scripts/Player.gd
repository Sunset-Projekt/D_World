extends "res://Scripts/ADAM.gd"

enum States { 
	IN_AIR, 
	ON_FLOOR,  
	ON_WALL,
	DEAD
}


const JUMP_POWER = 128
const ACCELERATION = 500
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02


onready var player = $AudioStreamPlayer2D
onready var MDP = $Melee_Damage_Pos
onready var cast = $RayCast2D
onready var other_cast = $RayCast2D2
onready var suka = get_node("/root/World/Level/Enemy")


var current_state = States.ON_FLOOR
var second_jump = false
var dash_state = true
var velocity: Vector2 = Vector2.ZERO
var MOVE_SPEED = 120 
var current_damage = 20


func _ready():
	add_to_group(GlobalVars.entity_group)
	self.health_points = 150
	self.max_health_points = 150
	set_start_hp(self.health_points, self.max_health_points)


func update_state():
	if self.health_points > 0:
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
	else:
		current_state = States.DEAD


func _physics_process(delta):
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var seat_state = Input.is_action_pressed("ui_down") or (cast.is_colliding() or other_cast.is_colliding())
	
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
		States.DEAD:
			print("DEAD")
	
	MDP.position = get_global_mouse_position() - position
	MDP.position.x = clamp(MDP.position.x, -20, 20)
	MDP.position.y = clamp(MDP.position.y, -20, 20)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	update_state()


func _unhandled_input(event):
	if event.is_action_pressed("left_click"):
		var a = load("res://Scenes/Melee_Damage_Area.tscn").instance()
		a.set_damage(current_damage)
		get_parent().add_child(a)
		a.position = self.position + MDP.position


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


func jump(_delta, direction):
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

func dash(_delta, _direction):
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
