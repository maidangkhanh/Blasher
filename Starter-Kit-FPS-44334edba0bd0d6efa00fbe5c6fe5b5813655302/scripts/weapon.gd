extends Resource
class_name Weapon

@export_subgroup("Model")
@export var model:PackedScene # Model of the weapon
@export var position:Vector3 # On-screen position
@export var rotation:Vector3 = Vector3(0, 180, 0)# On-screen rotation
@export var muzzle_position:Vector3 = Vector3(0.1, -0.4, 1.5) # On-screen position of muzzle flash

@export_subgroup("Properties")
@export_range(0.1, 1) var cooldown: float = 0.1 # Firerate
@export_range(1, 20) var max_distance: int = 50 # Fire distance
@export_range(0, 100) var damage: float = 25 # Damage per hit
@export_range(0, 5) var spread: float = 0 # Spread of each shot
@export_range(1, 5) var shot_count: int = 1 # Amount of shots
#@export_range(0, 50) var knockback: int = 20 # Amount of knockback
@export_range(1, 5) var reload_time:float = 2 # Time to Reload
@export_range(1, 200) var max_ammo:int = 30 # Maximum ammunitions
@export_range(0, 1) var recoil_rate:float = 0.5 # Recoil rate, higher mean more recoil
var current_ammo: int

@export_subgroup("Sounds")
@export var sound_shoot: String # Sound path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D # Image of crosshair on-screen

func setup():
	current_ammo = max_ammo

func shoot():
	current_ammo-=1
	
func reload():
	current_ammo = max_ammo

func mag_empty():
	return current_ammo <=0
