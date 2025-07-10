# Este script maneja objetos estáticos con los que se puede interactuar
# osea para cofres, tiendas, etc.
extends StaticBody3D


# SEÑALES QUE EMITE ESTE OBJETO
# Se emite cuando el jugador interactúa con este objeto
# Envía una referencia a sí mismo como "dueño" del inventario externo
signal toggle_inventory(external_inventory_owner)

# variable exportada
# Datos del inventario que contiene este objeto (items del cofre, tienda, etc.)
@export var inventory_data: InventoryData

# FUNCIÓN DE INTERACCIÓN CON EL JUGADOR
func player_interact() -> void:
	
	# Eemite la señal
	# Cuando el jugador interactúa (con la tecla E):
	# - Emite la señal toggle_inventory
	# - Pasa 'self' como parámetro, indicando que ESTE objeto es el dueño del inventario externo
	# - Esto permite que el sistema de inventario sepa qué inventario mostrar
	toggle_inventory.emit(self)


# explicacion
# 1. El jugador se acerca al objeto (cofre, contenedor, etc.)
# 2. Presiona la tecla de interacción (detectada por el RayCast3D del jugador)
# 3. El sistema del jugador llama a player_interact() en este objeto
# 4. Este objeto emite la señal toggle_inventory pasándose a sí mismo como parámetro
# 5. El controlador principal del inventario recibe la señal y:
#    - Abre la interfaz del inventario
#    - Configura este objeto como el inventario externo
#    - Permite al jugador transferir items entre su inventario y este contenedor
