extends Node3D

@onready var position_label := $PositionText
@onready var velocity_label := $VelocityText
@onready var status_label := $StatusText

var position_format := "Position X: %s / Y: %s / Z: %s"
var velocity_format := "Velocity X: %s / Y: %s / Z: %s"
var status_format := "Status: %s"

#Player variables
@onready var player: Player_entity = get_node("../")

func _process(delta):
	_set_debug_overlay()
	
func _set_debug_overlay() -> void:
	position_label.text = position_format % [
		"%.2f" % player.position.x, 
		"%.2f" % player.position.y, 
		"%.2f" % player.position.z
	]
	
	velocity_label.text = velocity_format % [
		"%.2f" % player.velocity.x, 
		"%.2f" % player.velocity.y, 
		"%.2f" % player.velocity.z
	]
	
	status_label.text = status_format % [player.StatusType.find_key(player.status)]


