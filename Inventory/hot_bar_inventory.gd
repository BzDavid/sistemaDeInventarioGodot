# Este script maneja la barra de acceso rápido del inventario
extends PanelContainer

# señal para poder usar los elementos en la barra de acceso rapido
# SEÑALES QUE EMITE ESTA BARRA
signal hot_bar_use(index: int)

# carga la escena 
# Reutiliza la misma escena de slot que se usa en el inventario principal
const Slot = preload("res://Inventory/slot.tscn")

# REFERENCIAS A NODOS
# Contenedor horizontal que organiza los slots en línea horizontal
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer

# FUNCIÓN PARA MANEJAR INPUT DE TECLAS
func _unhandled_key_input(event: InputEvent) -> void:
	# Si la barra no está visible o la tecla no está siendo presionada, no hace nada
	if not visible or not event.is_pressed():
		return
	
	# DETECCIÓN DE TECLAS NUMÉRICAS DEL 1 AL 67
	# Verifica si la tecla presionada está en el rango del 1 al 6
	if range(KEY_1, KEY_7).has(event.keycode):
		#calcula el indice
		# Convierte el código de tecla a índice del slot:
		# KEY_1 = índice 0, KEY_2 = índice 1, etc.
		# Emite la señal para usar el item en esa posición
		hot_bar_use.emit(event.keycode - KEY_1)

# conexion a los datos del inventario, la deacceso rapido
func set_inventory_data(inventory_data: InventoryData) -> void:
	# conex de actualizacion
	# Conecta la señal de actualización del inventario para refrescar la barra automáticamente
	inventory_data.inventory_updated.connect(populate_hot_bar)
	
	# Llama inmediatamente a la función para mostrar los items actuales
	populate_hot_bar(inventory_data)
	
	# uso
	# Conecta la señal hot_bar_use con la función use_slot_data del inventario
	# Esto permite que las teclas numéricas activen el uso de items directamente
	hot_bar_use.connect(inventory_data.use_slot_data)

# 
# FUNCIÓN PARA POBLAR LA BARRA DE ACCESO RÁPIDO
func populate_hot_bar(inventory_data: InventoryData) -> void:
	# LIMPIAR SLOTS EXISTENTES
	# Elimina todos los slots actuales de la barra
	for child in h_box_container.get_children():
		child.queue_free() # Eliminación segura al final del frame
	
	# REAR SLOTS PARA LOS PRIMEROS 6 ITEMS
	# slice(0, 6) toma solo los primeros 6 elementos del inventario
	# Esto limita la barra de acceso rápido a 6 slots máximo
	for slot_data in inventory_data.slot_datas.slice(0, 6):
		# Crea una nueva instancia del slot
		var slot = Slot.instantiate()
		
		# Añade el slot al contenedor horizontal
		# HBoxContainer automáticamente los organiza en línea horizontal
		h_box_container.add_child(slot)
		
		# ASIGNACIÓN DE DATOS
		# Si el slot tiene datos (no está vacío):
		if slot_data:
			# Configura el slot con los datos del item
			slot.set_slot_data(slot_data)
			# Si slot_data es null, el slot permanece vacío
		
		# NOTA: A diferencia del inventario principal, aquí NO se conecta slot_clicked
		# porque la barra de acceso rápido solo se usa con teclas numéricas
