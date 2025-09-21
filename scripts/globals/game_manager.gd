extends Node

var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")
var show_menu_on_start: bool = true

func _ready() -> void:
	if show_menu_on_start:
		call_deferred("show_game_menu_screen")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		show_game_menu_screen()

func start_game() -> void:
	unmute_sfx_bus()
	SceneManager.load_main_scene_container()
	await get_tree().process_frame  # Aguarda a main scene estar disponível
	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true
	
	#SceneManager.load_main_scene_container()
	#SceneManager.load_level("Level1")
	
func exit_game() -> void:
	get_tree().quit()
  
	
func show_game_menu_screen() -> void:
	mute_sfx_bus()
	var game_menu_screen_instance = game_menu_screen.instantiate()
	get_tree().root.add_child(game_menu_screen_instance)
	
func mute_sfx_bus() -> void:
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	if sfx_bus_index != -1:
		AudioServer.set_bus_mute(sfx_bus_index, true)
		print("Bus SFX mutado")

func unmute_sfx_bus() -> void:
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	if sfx_bus_index != -1:
		AudioServer.set_bus_mute(sfx_bus_index, false)
		print("Bus SFX desmutado - jogo iniciado")
