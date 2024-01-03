extends AnimatedSprite3D

@onready var player: Player_entity = get_node("../")
@onready var audio_listener := $AudioStreamPlayer
@onready var statuses := Player_entity.StatusType
@onready var blink_timer := $BlinkTimer

var is_timer_running: bool = false

func _process(_delta):
	_adjust_sprite_direction()
	
	match (player.status):	
		(statuses.UNDEFINED):
			play("falling")
		
		(statuses.WALKING): 
			play("running")
			
		(statuses.BLASTING):
			play("blasting")
			
		(statuses.JUMPING):
			play("jumping", 2)
			audio_listener.play()
		
			
		(statuses.FALLING):
			if (animation != "jump_rolling"):	
				play("falling")
			
		(statuses.DOUBLE_JUMPING):
			if (player.velocity.y > 0):
				play("double_jump")
				
			if (player.velocity.y < 1 and player.velocity.y > -1):
				_play_animation_once("jump_rolling", 2)
			
		(statuses.STANDING):
			_landing_handler()
			
			if (animation != "landing" and animation != "standing"):
				play("standing", 0)
				frame_progress = 1
			
			#Start blink timer
			if (not is_timer_running):
				frame_progress = 1
				blink_timer.start()
				is_timer_running = true
	
		(statuses.SLIDING):
			if (player.velocity.x != 0):
				play("sliding")
			else:
				_play_animation_once("standing")

func _adjust_sprite_direction() -> void:
	if player.direction.x < 0:
		flip_h = true
		
	if player.direction.x > 0:
		flip_h = false

func _on_animation_finished() -> void:
	if (animation == "jump_rolling"):
		animation = "falling"

	if (animation == "landing"):
		if (player.status == statuses.STANDING):
			animation = "standing"
			
		if (player.status == statuses.WALKING):
			animation = "walking"
			
		if (player.status == statuses.BLASTING):
			animation = "blasting"
			
func _landing_handler() -> void:
	if (animation == "falling"):
		_play_animation_once("landing")
		
func _on_blink_timer_timeout() -> void:
	is_timer_running = false
	if (player.status == statuses.STANDING):
		_play_animation_once("standing")
		
func _play_animation_once(_animation_name: String, _animation_speed: float = 1) -> void:
	play(_animation_name, _animation_speed)
	sprite_frames.set_animation_loop(_animation_name, false)	
