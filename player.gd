extends CharacterBody3D

@onready var camera_3d = $Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var SPEED = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
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
	
	if !is_on_floor():
		velocity.y-=gravity*delta
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward") #tutte le direzioni diverse da forward sono rotte :c
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))#.normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	print(is_on_floor())
	
	move_and_slide()
	
	
