#Este script maneja un slot individual del inventario
extends PanelContainer

#señal
# Se emite cuando se hace click en el slot, enviando el índice del slot y el botón presionado
signal slot_clicked(index: int, button: int)

#referenfias a la interfaz
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

# congiracion de los datos de los slots
func set_slot_data(slot_data: SlotData) -> void:
	# Obtiene los datos del item desde el slot_data
	var item_data = slot_data.item_data
	
	# configuracion de la textura de imagen
	# Asigna la textura del item al TextureRect para mostrar la imagen
	texture_rect.texture = item_data.texture
	
	# Crea un tooltip que muestra el nombre y descripción del item
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	# cantidad
	# Si hay más de 1 unidad del item:
	if slot_data.quantity > 1:
		# Muestra la cantidad en formato "x5", "x10", etc.
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show() # Hace visible la etiqueta
	else:
		# Si solo hay 1 unidad, oculta la etiqueta de cantidad
		quantity_label.hide()


# maneja el input del mouse, osea los click derecho e izquierdo
func _on_gui_input(event: InputEvent) -> void:
	# Verifica si el evento es un click del mouse
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
				
		# señal
		# Emite la señal slot_clicked con:
		# - get_index(): posición del slot en su contenedor padre
		# - event.button_index: qué botón del mouse se presionó (izquierdo/derecho)
		slot_clicked.emit(get_index(), event.button_index)
	
