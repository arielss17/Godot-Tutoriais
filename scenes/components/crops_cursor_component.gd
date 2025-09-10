class_name CropsCursorComponent
extends Node

@export var tilled_soil_tilemap_layer: TileMapLayer
@export var grass_tilemap_layer: TileMapLayer


@onready var player: Player = get_tree().get_first_node_in_group("player")

var tomato_plant_scene = preload("res://scenes/objects/plants/tomato.tscn")
var corn_plant_scene = preload("res://scenes/objects/plants/corn.tscn")

var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position: Vector2
var distance: float

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_cell_under_mouse()
			remove_crop()	
	elif event.is_action_pressed("hit"):
		if ToolManager.selected_tool == DataTypes.Tools.PlantCorn or ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
			get_cell_under_mouse()
			add_crop()

func get_cell_under_mouse() -> void:
	mouse_position = tilled_soil_tilemap_layer.get_local_mouse_position()
	cell_position = tilled_soil_tilemap_layer.local_to_map(mouse_position)
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = tilled_soil_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)

func has_tilled_dirt_at_position() -> bool:
	var tilled_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	return tilled_source_id != -1  # -1 = vazio, qualquer outro = tem tilled dirt

func is_valid_planting_spot() -> bool:
	return (distance < 20.0 && 	cell_source_id != -1 && has_tilled_dirt_at_position())
	
	
func add_crop() -> void:
	#print("=== PLANTIO DEBUG ===")
	#print("Distance: ", distance)
	#print("Grass source ID: ", cell_source_id)
	#print("Tilled dirt source ID: ", tilled_soil_tilemap_layer.get_cell_source_id(cell_position))
	
	if is_valid_planting_spot():
		if has_crop_at_position():
			#print("❌ JÁ TEM PLANTA AQUI!")
			return        
		#print("✅ PODE PLANTAR!")
		plant_selected_crop()
	#else:
			#if distance >= 20.0:
				#print("❌ MUITO LONGE!")
			#elif cell_source_id == -1:
				#print("❌ NÃO TEM GRAMA!")
			#elif !has_tilled_dirt_at_position():
				#print("❌ SOLO NÃO PREPARADO! Prepare com TillGround primeiro.")		
				
				
func plant_selected_crop() -> void:
	if ToolManager.selected_tool == DataTypes.Tools.PlantCorn:
		plant_crop(corn_plant_scene)
	elif ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
		plant_crop(tomato_plant_scene)

func has_crop_at_position() -> bool:
	var crop_nodes = get_parent().find_child("CropFields").get_children()
	for node: Node2D in crop_nodes:
		if node.global_position.distance_to(local_cell_position) < 5.0:
			return true
	return false

func plant_crop(plant_scene: PackedScene) -> void:
	var plant_instance = plant_scene.instantiate() as Node2D
	plant_instance.global_position = local_cell_position
	get_parent().find_child("CropFields").add_child(plant_instance)
	print("Planta adicionada em: ", local_cell_position)
		
func remove_crop() -> void:
	if distance < 20.0:
		var crop_nodes = get_parent().find_child("CropFields").get_children()
		for node: Node2D in crop_nodes:
			if node.global_position == local_cell_position:
				node.queue_free()
