extends PanelContainer


# Precarga la escena del slot individual que contendrá cada item
const Slot = preload("res://Inventory/slot.tscn")

# Referencia al GridContainer que organiza los slots en una cuadrícula
@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

# CONFIGURACIÓN DEL INVENTARIO
func set_inventory_data(inventory_data: InventoryData) -> void:
	# Conecta la señal que se emite cuando el inventario se actualiza
	# permite que la interfaz se actualice automáticamente cuando cambian los datos
	inventory_data.inventory_updated.connect(populate_item_grid)
	# Llama  a la función para poblar la cuadrícula con los datos actuales
	populate_item_grid(inventory_data)

# LIMPIEZA DEL INVENTARIO
func clear_inventory_data(inventory_data: InventoryData) -> void:
	# Desconecta la señal de actualización para evitar errores cuando se cierra el inventario
	# Esto hace que no se intente actualizar una interfaz que ya no existe
	inventory_data.inventory_updated.disconnect(populate_item_grid)

# FUNCIÓN PRINCIPAL - POBLAR LA CUADRÍCULA DE ITEMS
func populate_item_grid(inventory_data: InventoryData) -> void:
		#limpia los slots existentes
		# Recorre todos los slots que ya existen en la cuadrícula
	for child in item_grid.get_children():
		# queue_free() marca el nodo para ser eliminado al final del frame
		# Es más seguro que free() porque evita errores si algo más está usando el nodo
		child.queue_free()
	
	# crea nuevos slots
	# Recorre todos los datos de slots en el inventario
	for slot_data in inventory_data.slot_datas:
		# Crea una nueva instancia de la escena Slot
		var slot = Slot.instantiate()
		
		# Añade el nuevo slot como hijo del GridContainer
		# El GridContainer automáticamente lo posiciona en la cuadrícula
		item_grid.add_child(slot)
		
		
		#  SEÑALES
		# Conecta la señal del click del slot con la función correspondiente en inventory_data
		# esto hace que cuando le des click en un slot, se ejecute la lógica del inventario
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		# ASIGNACIÓN DE DATOS
		# Si el slot tiene datos (no está vacío):
		if slot_data:
		# Asigna los datos del item al slot para que se muestre correctamente
			slot.set_slot_data(slot_data)
		# Si slot_data es null, el slot permanece vacío 
