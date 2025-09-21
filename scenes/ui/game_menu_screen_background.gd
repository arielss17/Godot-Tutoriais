extends Node2D

func _ready() -> void:
	call_deferred("set_scene_process_mode")
	call_deferred("mute_sfx_bus")

	
func set_scene_process_mode() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	
func mute_sfx_bus() -> void:
	# Encontra o índice do bus SFX
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	if sfx_bus_index != -1:
		AudioServer.set_bus_mute(sfx_bus_index, true)
		print("Bus SFX mutado para a tela de menu")
	else:
		print("Erro: Bus 'SFX' não encontrado!")
