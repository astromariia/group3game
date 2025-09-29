extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func bgm_play():
	var stream = preload("res://Music/01 The Misadventure Begins from Cor Metallicum by Ozzed.mp3")
	audio_stream_player.volume_db = -20
	if stream is AudioStream:
		stream.loop = true
	audio_stream_player.stream = stream
	audio_stream_player.play()
	
