extends CharacterBody3D

class_name Player

@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 7

@export_subgroup("Weapons")
@export var weapons: Array[Weapon] = []

@export var weapon_index := 0
var weapon: Weapon

var mouse_sensitivity = 700
var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input: Vector3
var input_mouse: Vector2

var health:int = 100
var gravity := 0.0

var previously_floored := false

var jump_single := true
var jump_double := true

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween:Tween

signal health_updated(health_value)
signal ammo_updated(ammo_description)
signal reloading_start(reload_time)
signal reloading_finish
signal reload_interupt

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown
@onready var reload_timer = $"Reload Timer"
@onready var visual = $Head/Camera/Visual
@onready var muzzle_flash = $Head/Camera/MuzzleFlash

@export var crosshair:TextureRect

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


# Functions
func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	health_updated.emit()
	crosshair = get_tree().root.get_node("Main/CanvasLayer/HUD/Crosshair")
	initiate_change_weapon(weapon_index)
	change_weapon_visual.rpc(weapon_index)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement

	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Reset weapon container position after recoil
		
	container.position = lerp(container.position, container_offset - (applied_velocity / 30), delta * 20)
	
	# Movement sound
	
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			if sound_footsteps.autoplay != true: # Movement sound enable on first step
				sound_footsteps.autoplay = true
				sound_footsteps.play()
			sound_footsteps.stream_paused = false
	
	# Landing after jump or falling
	
	# camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		#camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	

# Mouse movement
func _input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion and mouse_captured:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func handle_controls(_delta):	
	# Mouse capture
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# Movement
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	movement_velocity = input.normalized() * movement_speed
	
	# Reloading
	action_reload()
	
	# Shooting
	action_shoot()

	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			jump_double = false
			
		if(jump_single): action_jump()
		
	# Weapon switching
	
	action_weapon_toggle()

# Handle gravity
func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping
func action_jump():
	
	gravity = -jump_strength
	
	jump_single = false;
	jump_double = true;

# Shooting
func action_shoot():
	
	if Input.is_action_pressed("shoot"):

		# Cooldown for shooting or in reloading
		# Also NULL check for weapon
		if !blaster_cooldown.is_stopped() or !reload_timer.is_stopped() or weapon == null: return 

		# Auto reload if press shoot while magazine is empty
		if weapon.mag_empty() and reload_timer.is_stopped():
			start_reload()
			return

		Audio.play(weapon.sound_shoot)
		
		# Recoil
		container.position.z += 0.25 # Knockback of weapon visual
		camera.rotation.x += randf_range(0.015, 0.03) # Knockback of camera vertically
		camera.rotation.y += randf_range(-0.005, 0.005) # Knockback of camera horizontally
		
		# Set muzzle flash position, play animation
		play_shoot_effect.rpc()
		
		muzzle.play("default")

		muzzle.rotation_degrees.z = randf_range(-45, 45)
		muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
		muzzle.position = container.position - weapon.muzzle_position

		blaster_cooldown.start(weapon.cooldown)

		# Shoot the weapon, amount based on shot count
		weapon.shoot()
		ammo_update()
#	

# Toggle between available weapons (listed in 'weapons')
func action_weapon_toggle():
	
	if Input.is_action_just_pressed("weapon_toggle"):
		health_updated.emit(health)
		weapon_index = wrap(weapon_index + 1, 0, weapons.size())
		initiate_change_weapon(weapon_index)
		
		Audio.play("sounds/weapon_change.ogg")
		
		change_weapon_visual.rpc(weapon_index)

# Reload weapon
func action_reload():
	if Input.is_action_just_pressed("reload"):
		if weapon.current_ammo < weapon.max_ammo:
			start_reload()

# Initiates the weapon changing animation (tween)
func initiate_change_weapon(index):
	
	weapon_index = index
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon)# Changes the model


# Switches the weapon model (off-screen)
func change_weapon():	
	interupt_reload()
	weapon = weapons[weapon_index]
	
	# Step 1. Remove previous weapon model(s) from container
	
	for n in container.get_children():
		container.remove_child(n)
	
	# Step 2. Place new weapon model in container
	
	var weapon_model = weapon.model.instantiate()
	container.add_child(weapon_model)
	
	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation
	
	# Step 3. Set model to only render on layer 2 (the weapon camera)
	
	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2
		
	# Set weapon data
	
	raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
	crosshair.texture = weapon.crosshair
	ammo_update()

@rpc("any_peer","reliable")
func damage(amount):
	health -= amount
	health_updated.emit(health) # Update health on HUD
	
	# Respawn
	if health <= 0:
		health = 100
		health_updated.emit(health)
		position = Vector3.ZERO # Reset when out of health

# HUD ammo update
func ammo_update():	
	ammo_updated.emit(str(weapon.current_ammo) + " / " + str(weapon.max_ammo))

func start_reload():
	# TODO: reload sound
	reload_timer.start(weapon.reload_time)
	reloading_start.emit(weapon.reload_time)

func _on_reload_timer_timeout():
	weapon.reload()
	ammo_update()
	reloading_finish.emit()
	

func interupt_reload():
	reload_timer.stop()
	reload_interupt.emit()

func reset_scence():
	for _weapon in weapons:
		_weapon.current_ammo = _weapon.max_ammo
	get_tree().reload_current_scene()

@rpc("any_peer", "call_local")
func change_weapon_visual(index):
	for n in visual.get_children():
		visual.remove_child(n)
	
	var weapon_model = weapons[index].model.instantiate()
	visual.add_child(weapon_model)
	
	weapon_model.rotation = camera.rotation

func show_weapon_visual():
	muzzle_flash.show()
	visual.show()

@rpc("call_local")
func play_shoot_effect():
	muzzle_flash.play("default")
	
	muzzle_flash.rotation_degrees.z = randf_range(-45, 45)
	muzzle_flash.scale = Vector3.ONE * randf_range(0.40, 0.75)
	muzzle_flash.position = visual.position - weapons[weapon_index].muzzle_position * 0.3

	
	for n in weapons[weapon_index].shot_count:
	
		raycast.target_position.x = randf_range(-weapons[weapon_index].spread, weapons[weapon_index].spread)
		raycast.target_position.y = randf_range(-weapons[weapon_index].spread, weapons[weapon_index].spread)
		
		raycast.force_raycast_update()
		
		if !raycast.is_colliding(): continue # Don't create impact when raycast didn't hit
		
		var collider = raycast.get_collider()
		
		# Hitting an enemy			
		if collider.has_method("damage"):
			collider.damage.rpc(weapons[weapon_index].damage)
		
		# Creating an impact animation			
		var impact = preload("res://objects/impact.tscn")
		var impact_instance = impact.instantiate()
		
		impact_instance.play("shot")
		
		get_tree().root.add_child(impact_instance)
		
		impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
		impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true) 
