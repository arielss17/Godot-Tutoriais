extends Node2D

var balloon_scene = preload("res://dialogue/game_dialogue_balloon.tscn")

@onready var interactable_component: InteractableComponent = $InteractableComponent

signal guide_interactable_activated
signal guide_interactable_deactivated

var in_range:bool

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	
	GameDialogueManager.give_crop_seeds.connect(on_give_crop_seeds)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		guide_interactable_activated.connect(player.on_interaction_started)
		guide_interactable_deactivated.connect(player.on_interaction_ended)

func on_give_crop_seeds() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.TillGround)
	ToolManager.enable_tool_button(DataTypes.Tools.WaterCrops)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantCorn)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantTomato)
	
	
func on_interactable_activated() -> void:
	guide_interactable_activated.emit()
	in_range = true
	
func on_interactable_deactivated() -> void:
	guide_interactable_deactivated.emit()
	in_range = false
	
func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialogue"):
			var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
			get_tree().root.add_child(balloon)
			balloon.start(load("res://dialogue/conversations/guide.dialogue"),"start")
