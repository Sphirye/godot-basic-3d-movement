extends Node

@onready var player: Player_entity = get_node("../")
@onready var statuses := Player_entity.StatusType
@onready var audio_players = $AudioPlayers

var jump_vox_sound = load("res://assets/sounds/Starfruit_Jump_Vox.mp3")
var jump_resource_sound = load("res://assets/sounds/Starfruit_Jump_Resource.mp3")
var slide_vox_sound = load("res://assets/sounds/Starfruit_Slide_Vox.mp3")

var rng = RandomNumberGenerator.new()

func _on_player_entity_status_signal(status: Player_entity.StatusType) -> void:
	match(player.status):
		
		(statuses.JUMPING):
			_play_sound(jump_resource_sound, 1, -7)
			_play_sound(jump_vox_sound, rng.randf_range(0.9, 1.1), -7)
			
		(statuses.DOUBLE_JUMPING):
			_play_sound(jump_resource_sound, 1, -7)
			_play_sound(jump_vox_sound, rng.randf_range(0.9, 1.1), -7)
			
		(statuses.SLIDING):
			_play_sound(slide_vox_sound, rng.randf_range(1, 1.1), -7)

func _play_sound(sound_name: Resource, pitch: float = 1, volume: float = 1) -> void:
	for aps in audio_players.get_children():
		if (not aps.playing):
			aps.volume_db = volume
			aps.stream = sound_name
			aps.pitch_scale = pitch
			aps.play()
			break
