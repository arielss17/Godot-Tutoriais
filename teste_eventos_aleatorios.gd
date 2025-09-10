class_name AdvancedEventComponent
extends Node

# Lista de eventos possíveis
var events = [
	{
		"name": "evento_teste",
		"start_hour": 12,
		"end_hour": 24,
		"chance": 0.9,
		"message": "Teste de evento aleatorio"
	},
	{
		"name": "evento_madrugada", 
		"start_hour": 0,
		"end_hour": 6,
		"chance": 0.9,
		"message": "Evento da madrugada!"
	}
]

func _ready() -> void:
	DayAndNightCycleManager.time_tick.connect(on_time_tick)

func on_time_tick(day: int, hour: int, minute: int) -> void:
	if minute % 60 == 0: # Verifica a cada hora
		check_all_events(hour)

func check_all_events(current_hour: int) -> void:
	for event in events:
		if is_event_time(current_hour, event.start_hour, event.end_hour):
			if randf() <= event.chance:
				trigger_event(event)

func is_event_time(hour: int, start: int, end: int) -> bool:
	return hour >= start and hour < end

func trigger_event(event: Dictionary) -> void:
	print(event.message)
	# Aqui você pode chamar funções específicas baseadas no event.name
