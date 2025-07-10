extends Control


signal drop_slot_data(slot_data : SlotData) # Se emite cuando se suelta un item fuera del inventario
signal force_close # Se emite para forzar el cierre del inventario


# variables del sistema 
var grabbed_slot_data: SlotData # Dato del item que está siendo arrastrado
var external_inventory_owner # Referencia al inventario externo (cofre, tienda, etc.)


# paneles de la interfaz
@onready var player_inventory: PanelContainer = $PlayerInventory # inventario del jugador
@onready var grabbed_slot: PanelContainer = $GrabbedSlot # Panel del item siendo arrastrado
@onready var external_inventory: PanelContainer = $ExternalInventory # Panel del inventario externo
@onready var equip_inventory: PanelContainer = $EquipInventory # Panel del inventario de equipamiento

# funcion de proceso de la fisica (se ejecuta constantemente)
func _physics_process(delta: float) -> void:
	
	# seguimiento del mouse para item arrastrado
	# Si hay un item siendo arrastrado, sigue la posición del mouse
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
		
		# cierra automaticamente el inventario
		# Si hay un inventario externo y el jugador se aleja más de 4 unidades, cierra automáticamente
		# cerrar el cofre a distancia por el bug
	if external_inventory_owner \
			and external_inventory_owner.global_position.distance_to(PlayerManager.get_global_position()) > 4:
		force_close.emit()

# CONFIGURACIÓN DEL INVENTARIO DEL JUGADOR
func set_player_inventory_data(inventory_data: InventoryData) -> void:
	# Conecta la señal de interacción del inventario con la función local
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Asigna los datos del inventario al panel del jugador
	player_inventory.set_inventory_data(inventory_data)
	
# CONFIGURACIÓN DEL INVENTARIO DE EQUIPAMIENTO
func set_equip_inventory_data(inventory_data: InventoryData) -> void:
	# Conecta la señal de interacción del inventario de equipamiento
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Asigna los datos al panel de equipamiento
	
	equip_inventory.set_inventory_data(inventory_data)

# CONFIGURACIÓN DEL INVENTARIO EXTERNO (cofres, tiendas, etc.)
func set_external_inventory(_external_inventory_owner) -> void:
	
	# Guarda la referencia al dueño del inventario externo
	external_inventory_owner = _external_inventory_owner
	
	# Obtiene los datos del inventario externo
	var inventory_data = external_inventory_owner.inventory_data
	
	# Conecta la señal de interacción
	inventory_data.inventory_interact.connect(on_inventory_interact)
	
	# Asigna los datos al panel externo
	external_inventory.set_inventory_data(inventory_data)
	
	# muestra el inventario externo
	external_inventory.show()

# LIMPIEZA DEL INVENTARIO EXTERNO
func clear_external_inventory() -> void:
	# Si existe un inventario externo activo:
	if external_inventory_owner:
		# Obtiene los datos del inventario
		var inventory_data = external_inventory_owner.inventory_data
		
		# Desconecta la señal de interacción
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		
		# Limpia los datos del panel
		external_inventory.clear_inventory_data(inventory_data)
		
		# Oculta el panel y limpia la referencia
		external_inventory.hide()
		external_inventory_owner = null

# FUNCIÓN PRINCIPAL DE INTERACCIÓN CON INVENTARIOS
func on_inventory_interact(inventory_data: InventoryData,
# Usa pattern matching para manejar diferentes combinaciones de estados y botones
index: int, button: int) -> void:
	match [grabbed_slot_data, button]:
		# CLICK IZQUIERDO SIN ITEM EN MANO
		[null, MOUSE_BUTTON_LEFT]:
			# Agarra el item del slot clickeado
			grabbed_slot_data = inventory_data.grab_slot_data(index)
			# CLICK IZQUIERDO CON ITEM EN MANO
		[_, MOUSE_BUTTON_LEFT]:
			# Intenta colocar el item en el slot clickeado
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)

		# CLICK DERECHO SIN ITEM EN MANO
		[null, MOUSE_BUTTON_RIGHT]:
			# Usa el item del slot (consumir, equipar, etc.)
			inventory_data.use_slot_data(index)
			
			# CLICK DERECHO CON ITEM EN MANO
		[_, MOUSE_BUTTON_RIGHT]:
			# Coloca solo UNA unidad del item en el slot
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
			
	# Actualiza la visualización del item arrastrado
	update_grabbed_slot()

# ACTUALIZACIÓN DE LA VISUALIZACIÓN DEL ITEM ARRASTRADO
func update_grabbed_slot() -> void:
	# Si hay un item siendo arrastrado:
	if grabbed_slot_data:
		grabbed_slot.show() # Muestra el panel
		grabbed_slot.set_slot_data(grabbed_slot_data) # Asigna los datos
	else:
		grabbed_slot.hide() # Oculta el panel

# MANEJO DE INPUT DIRECTO EN LA INTERFAZ
func _on_gui_input(event: InputEvent) -> void:
	# Si es un click del mouse Y está presionado Y hay un item en mano:
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data:
		
		match event.button_index:
			# CLICK IZQUIERDO: Suelta todo el stack del item
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
			# CLICK DERECHO: Suelta solo una unidad del item
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		# Actualiza la visualización
		update_grabbed_slot()
	

# MANEJO DEL CIERRE DE LA INTERFAZ
func _on_visibility_changed() -> void:
	# Si la interfaz se oculta Y hay un item en mano:
	if not visible and grabbed_slot_data:
		# Suelta el item automáticamente
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
