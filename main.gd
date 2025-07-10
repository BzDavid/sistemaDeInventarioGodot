extends Node

# -- controlador principal que gestiona toda la interfaz del inventario del jugador 
# -- y las interacciones con inventarios externos -- :D

# recarga la escena del item que se puede agarrar del piso
const PickUp = preload("res://item/pick_up/pick_up.tscn")

# -- referencias a nodos que estan en la escena -- #
@onready var player: CharacterBody3D = $Player # -- referencia al jugador
@onready var inventory_interface: Control = $UI/InventoryInterface # -- la interfaz del inventario 
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory # -- Barra de acceso rapido

# inicializacion 
func _ready() -> void:
	# conecta la señal del jugador para abrir y cerrar el inventario
	player.toggle_inventory.connect(toggle_inventory_interface)
	
	# configura los datos del inventario del jugador en la interfaz
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	
	# conecta la señal para forzar el cierre del inventario
	inventory_interface.force_close.connect(toggle_inventory_interface)
	
	# configura los datos del inventario en la barra de acceso rápido
	hot_bar_inventory.set_inventory_data(player.inventory_data)
	
	# Busca todos los nodos en el grupo "external_inventory" (como cofres, tiendas, etc.)
	# y conecta sus señales para abrir inventarios externos
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

	# funcion para alternar la interfaz del inventario
func toggle_inventory_interface(external_inventory_owner = null) -> void:
	# Cambia la visibilidad del inventario 
	inventory_interface.visible = not inventory_interface.visible
	
	# Si el inventario está visible:
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		hot_bar_inventory.hide()
	else:
	
	# Si el inventario está oculto:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hot_bar_inventory.show()
	
	# Si hay un inventario externo (como el cofre):
	if external_inventory_owner and inventory_interface:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

# funcion de cuando se suelta un item del inventario
func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	
	# crea una instancia del item que se puede recoger
	var pick_up = PickUp.instantiate()
	# Asigna los datos del slot (tipo de item, cantidad, etc.) al objeto
	pick_up.slot_data = slot_data
	
	# posiciona el item donde lo soltamos (al item)
	pick_up.position = player.get_drop_position()
	
	# Añade el item al mundo como hijo de este nodo, crea una relación donde el nuevo nodo
	# (el item) se convierte en parte del nodo existente (el padre)
	add_child(pick_up)
