class_name Coin
extends RigidBody3D
signal collected
var point:int=5
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(90)*delta)
	pass

#aumento i punti e cambiare di posizione in caso in cui la moneta sovrappongono agli ostacoli
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		collected.emit(point)
		visible=false;
		audio.play()
	pass # Replace with function body.



func _on_audio_stream_player_3d_finished() -> void:
	call_deferred("queue_free")
	pass # Replace with function body.
