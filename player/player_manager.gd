extends Node

var player

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)

# arreglar un bug que habia en el cofre, que a pesar de la distancia
# no se cerraba el inventario del cofre :D

func get_global_position()  -> Vector3:
	return player.global_position
