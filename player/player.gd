extends CharacterBody3D

@export var inventory_data: InventoryData # Datos del inventario principal del jugador
@export var equip_inventory_data: InventoryDataEquip # Datos del inventario de equipamiento
 
# CONSTANTE DE MOVIMIENTO
const SPEED = 5.0 # Velocidad de movimiento del jugador
const JUMP_VELOCITY = 4.5 # Velocidad del salto
 
# Obtiene la gravedad de la configuración del proyecto para sincronizar con RigidBody
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var health : int = 5 # Vida 

signal toggle_inventory() # Señal para abrir/cerrar inventario

# REFERENCIAS A NODOS
@onready var camera: Camera3D = $Camera3D
@onready var interact_ray: RayCast3D = $Camera3D/InteractRay

# INICIALIZACIÓN
func _ready() -> void:
	# Registra al jugador en el PlayerManager (singleton)
	
	PlayerManager.player = self
	
	# Captura el mouse para el modo FPS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 

# Funcion para manejar el input (eventos de mouse y teclado) 
func _unhandled_input(event: InputEvent) -> void:
	
	# control de la camara
	if event is InputEventMouseMotion:
		
		# Rotación horizontal (eje y) 
		rotate_y(-event.relative.x * .005)
		
		# Rotación vertical (eje X)
		camera.rotate_x(-event.relative.y * .005)
		
		# le pone un limite a la rotacion vertical para evitar que la camara se vaya(se voltee)
		camera.rotation.x = clamp(camera.rotation.x, -PI/4, PI/4)
	
	# sale del juegaso
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	# abre y cierra el inventario
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	
	# interactua con los objetos
	if Input.is_action_just_pressed("Interact"):
		interact()
 
 
# funcion de fisicas (se ejecuta a 60 FPS)
func _physics_process(delta: float) -> void:
	
	# aplica la gravedad
	# Si no está en el piso, aplica gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
 
	# salto
	# Si presiona saltar y está en el suelo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
 
	#Movimiento
	# Agarra el vector de dirección basado en las teclas presionadas
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	
	# Convierte la dirección de input a dirección global basada en la rotación del jugador
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Si hay dirección de movimiento:
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
	# Si no hay tecla presionada (input), desacelera gradualmente
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
   
	# movimiento con detección de colisiones
	move_and_slide()
 
# interaccion
func interact() -> void:
	# Si el rayo de interacción está colisionando con algo:
	if interact_ray.is_colliding():
		# Llama a la función player_interact() del objeto con el que colisiona
		interact_ray.get_collider().player_interact()


# obtiene la posicion de donde suelta los items
func get_drop_position() -> Vector3:
	# Obtiene la dirección hacia adelante de la cámara
	var direction = -camera.global_transform.basis.z
	
	# Devuelve la posición de la cámara un poco mas hacia adelante
	return camera.global_position + direction

# funcion para curar al jugador, solamente que creo que no llegamos
func heal(heal_value: int) -> void:
	
	# Aumenta la vida del jugador
	health += heal_value
	
