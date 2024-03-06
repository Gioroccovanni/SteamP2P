extends CharacterBody3D

@onready var camera_3d = $Camera3D
@onready var csg_box_3d = $CSGBox3D

var SPEED = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(str(is_multiplayer_authority()))
	if not is_multiplayer_authority(): return
	
	camera_3d.current = is_multiplayer_authority()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion and Input.mouse_mode == 2:
		rotate_y(-event.relative.x * .005)
		camera_3d.rotate_x(-event.relative.y * .005)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, -PI/2, PI/2)	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_multiplayer_authority(): return

	var input_dir = Input.get_vector("left", "right", "forward", "backward") #tutte le direzioni diverse da forward sono rotte :c
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		#look_at(position + direction)	
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
