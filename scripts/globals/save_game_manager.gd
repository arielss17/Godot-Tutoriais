extends Node

var allow_save_game: bool

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game()

func save_game() -> void:
	var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	if save_level_data_component != null:
		save_level_data_component.save_game()
		

#func load_game() -> void:
	#await get_tree().process_frame
	#var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	#if save_level_data_component != null:
		#save_level_data_component.load_game()
func load_game() -> void:
	# Aguarda até que o componente esteja disponível
	var save_level_data_component: SaveLevelDataComponent
	var max_attempts = 10
	var attempts = 0
	
	while save_level_data_component == null and attempts < max_attempts:
		await get_tree().process_frame
		save_level_data_component = get_tree().get_first_node_in_group("save_level_data_component")
		attempts += 1
	
	if save_level_data_component != null:
		save_level_data_component.load_game()
	else:
		print("SaveLevelDataComponent não encontrado após ", max_attempts, " tentativas!")
