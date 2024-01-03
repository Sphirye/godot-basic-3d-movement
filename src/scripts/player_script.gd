extends CharacterBody3D

class_name Player_entity

@onready var twist_pivot := $CameraNode/TwistPivot
@onready var pitch_pivot := $CameraNode/TwistPivot/PitchPivot
@export var status := StatusType.UNDEFINED
@export var direction := Vector3.ZERO

const speed = 3
const blast_speed = 2.5
const jump_velocity = 5
const double_jump_velocity = 4
const friction = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var freeze_movement: bool = false
var avaliable_jumps = 1

signal status_signal(status: StatusType)

enum StatusType {
	STANDING, 
	WALKING,
	BLASTING,
	JUMPING,
	DOUBLE_JUMPING,	
	FALLING,
	LANDING,
	SLIDING,
	UNDEFINED,
}

func _process(delta):
	_proccess_statuses()	
	_process_movement(delta)
	move_and_slide()

func _process_movement(delta: float):  	
	
	#Horizontal movement
	var input_dir = Input.get_vector("move_right", "move_left", "move_foward", "move_back")
	direction = (twist_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if (direction and freeze_movement):
		velocity.x = direction.x * speed
		
		if (Input.is_action_pressed("move_blast")):
			velocity.x = velocity.x + (blast_speed * direction.x)
			
#		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * friction * delta)
		velocity.z = move_toward(velocity.z, 0, speed * friction * delta)
	
	if (is_on_floor()):
		avaliable_jumps = 1
		freeze_movement = not Input.is_action_pressed("ui_down")
			
	if (not is_on_floor()):
		velocity.y -= gravity * delta
		if (avaliable_jumps != 0 and Input.is_action_just_pressed("move_jump")):
			avaliable_jumps -= 1
			velocity.y = double_jump_velocity
	
	#Jump
	if (Input.is_action_just_pressed("move_jump") and is_on_floor()):
		velocity.y = jump_velocity
		
func _proccess_statuses() -> void:
	if is_on_floor():
		
		if (direction.x == 0):
			status = StatusType.STANDING
		
		if (direction.x != 0):
			
			if (Input.is_action_pressed("move_blast")):
				status = StatusType.BLASTING				
			else:
				status = StatusType.WALKING
	
			if (Input.is_action_just_pressed("ui_down")):
				if (status != StatusType.SLIDING):
					status = StatusType.SLIDING
					status_signal.emit(StatusType.SLIDING)
	
			if (Input.is_action_pressed("ui_down")):
				status = StatusType.SLIDING
				
		if (Input.is_action_just_pressed("move_jump")):
			status = StatusType.JUMPING
			status_signal.emit(StatusType.JUMPING)

	if not is_on_floor():
		
		if (status == StatusType.WALKING and velocity.y < -2):
			status = StatusType.FALLING
		
		if (status == StatusType.JUMPING) or (status == StatusType.DOUBLE_JUMPING):
			if (_is_falling()):
				status = StatusType.FALLING
				
		if (avaliable_jumps != 0 and Input.is_action_just_pressed("move_jump")):
			status = StatusType.DOUBLE_JUMPING
			status_signal.emit(StatusType.JUMPING)			

func _is_moving() -> bool:
	return velocity.x != 0 || velocity.z != 0

func _is_falling() -> bool:
	return velocity.y < 0 && !is_on_floor()

func _is_trying_to_move() -> bool:
	return direction.x != 0
