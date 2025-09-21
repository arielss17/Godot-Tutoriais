class_name Player
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent
@onready var interactable_label: Control = $InteractableLabelComponent


@export var current_tool:DataTypes.Tools = DataTypes.Tools.None

var player_direction: Vector2

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	if interactable_label:
		interactable_label.hide()

func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool
	hit_component.current_tool = tool

func on_interaction_started() -> void:
	if interactable_label:
		interactable_label.show()
		#print("Pode interagir com o Guide!")

func on_interaction_ended() -> void:
	if interactable_label:
		interactable_label.hide()
		#print("Saiu da área do Guide")
