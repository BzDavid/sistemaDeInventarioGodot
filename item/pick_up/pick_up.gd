# Este script maneja items físicos que se pueden recoger del mundo
# RigidBody3D permite que el item tenga física realista (caída, rebote, etc.)

extends RigidBody3D

# Contiene todos los datos del item (tipo, cantidad, propiedades, etc.)
@export var slot_data: SlotData

# Sprite3D que muestra la imagen del item en el mundo 3D
@onready var sprite_3d: Sprite3D = $Sprite3D

# FUNCIÓN DE INICIALIZACIÓN
func _ready() -> void:
	
	# CONFIGURACIÓN VISUAL
	# Asigna la textura del item al Sprite3D para mostrarlo visualmente
	# Obtiene la textura desde: slot_data -> item_data -> texture
	sprite_3d.texture = slot_data.item_data.texture

# FUNCIÓN DE PROCESO DE FÍSICA
func _physics_process(delta: float) -> void:
	
	# ANIMACIÓN DE ROTACIÓN
	# Hace que el sprite rote constantemente en el eje Y
	# Esto crea un efecto visual típico de items en el suelo (rotación lenta y continua)
	# delta asegura que la rotación sea consistente independientemente del framerate
	sprite_3d.rotate_y(delta)

# funcion de deteccion de cuando lo agarras
func _on_area_3d_body_entered(body: Node3D) -> void:
	# verifica y agarra
	# Cuando un cuerpo entra en el área de detección:
	# 1. Intenta añadir el item al inventario del cuerpo que entró
	# 2. pick_up_slot_data() devuelve true si se pudo añadir exitosament
	if body.inventory_data.pick_up_slot_data(slot_data):
		# elimina el item
		# Si el item se recogió exitosamente, elimina este objeto del mundo
		# queue_free() marca el objeto para eliminación al final del fram
		queue_free()

# EXPLICACIÓN DEL FLUJO COMPLETO:
# 1. El item se crea en el mundo (cuando se suelta del inventario o aparece naturalmente)
# 2. Cae al suelo usando la física de RigidBody3D
# 3. Rota constantemente para llamar la atención del jugador
# 4. Cuando el jugador se acerca y toca el área de detección:
#    - Se intenta añadir al inventario del jugador
#    - Si hay espacio, se recoge y desaparece del mundo
#    - Si no hay espacio, permanece en el suelo

# COMPONENTES NECESARIOS EN LA ESCENA:
# - RigidBody3D (este script)
# - Sprite3D (para mostrar la imagen)
# - Area3D (para detectar cuando el jugador se acerca)
# - CollisionShape3D (para la física del RigidBody3D)
# - CollisionShape3D hijo del Area3D (para la detección de recogida)
