extends NodeState

@export var character: NonPlayableCharacter
@export var animated_sprite_2d: AnimatedSprite2D
@export var navigation_agent_2d: NavigationAgent2D
@export var min_speed: float = 5.0
@export var max_speed: float = 15.0

# Variáveis para detecção de stuck
@export var stuck_detection_distance: float = 2.0  # Distância mínima que deve se mover
@export var stuck_check_interval: float = 1.0      # Intervalo para verificar se está stuck
@export var max_stuck_time: float = 3.0            # Tempo máximo antes de forçar novo destino
@export var stuck_push_force: float = 20.0         # Força do "empurrão" quando travado

@onready var rng := RandomNumberGenerator.new()
@onready var stuck_timer: Timer = Timer.new()

var speed: float
var last_position: Vector2
var stuck_time: float = 0.0
var is_stuck: bool = false

func _ready() -> void:
	rng.randomize()
	navigation_agent_2d.velocity_computed.connect(on_safe_velocity_computed)
	
	# Configurar timer para detecção de stuck
	stuck_timer.wait_time = stuck_check_interval
	stuck_timer.timeout.connect(check_if_stuck)
	add_child(stuck_timer)
	
	call_deferred("character_setup")

func character_setup() -> void:
	await get_tree().physics_frame
	await get_tree().create_timer(rng.randf_range(0.0, 0.25)).timeout
	set_movement_target()

func set_movement_target() -> void:
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(
		navigation_agent_2d.get_navigation_map(),
		navigation_agent_2d.navigation_layers,
		false
	)
	navigation_agent_2d.target_position = target_position
	speed = rng.randf_range(min_speed, max_speed)
	
	# Reset das variáveis de stuck quando definir novo destino
	reset_stuck_detection()

func reset_stuck_detection() -> void:
	stuck_time = 0.0
	is_stuck = false
	last_position = character.global_position

func check_if_stuck() -> void:
	var current_position = character.global_position
	var distance_moved = current_position.distance_to(last_position)
	
	# Se moveu menos que a distância mínima, considera "stuck"
	if distance_moved < stuck_detection_distance:
		stuck_time += stuck_check_interval
		
		# Se ficou stuck por muito tempo, força um novo destino
		if stuck_time >= max_stuck_time:
			print("NPC ", character.name, " estava travado. Definindo novo destino...")
			is_stuck = true
			handle_stuck_npc()
	else:
		# Se moveu normalmente, reset o contador
		stuck_time = 0.0
		is_stuck = false
	
	last_position = current_position

func handle_stuck_npc() -> void:
	# Opção 1: Dar um "empurrão" em direção aleatória
	give_random_push()
	
	# Aguardar um pouco e então definir novo destino
	await get_tree().create_timer(0.5).timeout
	force_new_destination()

func give_random_push() -> void:
	# Gera uma direção aleatória para "empurrar" o NPC
	var random_direction = Vector2(
		rng.randf_range(-1.0, 1.0),
		rng.randf_range(-1.0, 1.0)
	).normalized()
	
	# Aplica o empurrão
	var push_velocity = random_direction * stuck_push_force
	character.velocity = push_velocity
	character.move_and_slide()

func force_new_destination() -> void:
	# Tenta encontrar um destino mais próximo para evitar stuck novamente
	var attempts = 0
	var max_attempts = 5
	
	while attempts < max_attempts:
		var new_target = NavigationServer2D.map_get_random_point(
			navigation_agent_2d.get_navigation_map(),
			navigation_agent_2d.navigation_layers,
			false
		)
		
		# Verifica se o novo destino não está muito longe
		var distance_to_target = character.global_position.distance_to(new_target)
		if distance_to_target < 100.0:  # Limite de distância para evitar destinos muito longes
			navigation_agent_2d.target_position = new_target
			break
		
		attempts += 1
	
	# Se não encontrou um destino próximo, usa um destino baseado na posição atual
	if attempts >= max_attempts:
		var fallback_target = character.global_position + Vector2(
			rng.randf_range(-50.0, 50.0),
			rng.randf_range(-50.0, 50.0)
		)
		navigation_agent_2d.target_position = fallback_target
	
	reset_stuck_detection()

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	# Verifica se chegou ao destino ou precisa de um novo
	if navigation_agent_2d.is_navigation_finished():
		character.current_walk_cycle += 1
		set_movement_target()
		return
	
	# Se está stuck, não processa movimento normal
	if is_stuck:
		return
	
	var target_position: Vector2 = navigation_agent_2d.get_next_path_position()
	var target_direction: Vector2 = character.global_position.direction_to(target_position)
	
	var velocity: Vector2 = target_direction * speed
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.velocity = velocity
	else:
		character.velocity = velocity
		animated_sprite_2d.flip_h = character.velocity.x < 0
		character.move_and_slide()

func on_safe_velocity_computed(safe_velocity: Vector2) -> void:
	if not is_stuck:
		character.velocity = safe_velocity
		animated_sprite_2d.flip_h = character.velocity.x < 0.0
		character.move_and_slide()

func _on_next_transitions() -> void:
	if character.current_walk_cycle >= character.walk_cycles:
		character.velocity = Vector2.ZERO
		transition.emit("idle")

func _on_enter() -> void:
	character.current_walk_cycle = 0
	animated_sprite_2d.play("walk")
	
	# Inicializar detecção de stuck
	last_position = character.global_position
	stuck_timer.start()

func _on_exit() -> void:
	animated_sprite_2d.stop()
	stuck_timer.stop()
	reset_stuck_detection()
