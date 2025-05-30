extends CharacterBody2D

@onready var animation: AnimationTree = $hider_animtree
@onready var camera: Camera2D = $hider_camera
@onready var dust_trail = $hider_dust_trail
@onready var ui_cloak = $hider_ui/ui_center/ui_cooldowns/ui_cloak
@onready var ui_cloak_timer = $hider_ui/ui_center/ui_cooldowns/ui_cloak/ui_cloak_timer

@export var speed: float = 100.0 # Base speed
@export var fade_duration: float = 0.5
@export var invisibility_duration: float = 3.0

# Default variables
var input_direction = Vector2.ZERO
var last_movement_direction: Vector2 = Vector2.DOWN
# Cloaking variables
var cloak_cooldown_ready: bool = true
var is_cloaking: bool = false
var timer: float = 0.0

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	if is_multiplayer_authority():
		camera.make_current()
	animation.active = true
	
func _process(delta):
	# Check if the dash key is not playing and on cooldown
	if Input.is_action_just_pressed("skill_key") and cloak_cooldown_ready:
		start_cloaking()
		cloak_cooldown_ready = false
		is_cloaking = true
		ui_cloak.value = 0
		$cloak_cooldown.start()
		ui_cloak_timer.start()
		
func _physics_process(delta):
	move_and_slide()
	update_animation_parameters()
	
	# Movement
	if is_multiplayer_authority():
		input_direction = Vector2(
			Input.get_action_strength("right_key") - Input.get_action_strength("left_key"),
			Input.get_action_strength("down_key") - Input.get_action_strength("up_key")
		).normalized()
		velocity = input_direction * speed
	
	if velocity.length() > 0:  # Check if the player is moving
		dust_trail.emitting = true
	else:
		dust_trail.emitting = false
		
	# Update last movement direction
	if input_direction != Vector2.ZERO: 
		last_movement_direction = input_direction
		
	# Invisibility handling
	if is_cloaking:
		timer += delta
		# Fade out
		if timer <= fade_duration:
			modulate.a = lerp(1.0, 0.0, timer / fade_duration)
		# Stay cloaked
		elif timer <= fade_duration + invisibility_duration:
			modulate.a = 0.0
		# Fade back in
		elif timer <= 2 * fade_duration + invisibility_duration:
			modulate.a = lerp(0.0, 1.0, (timer - fade_duration - invisibility_duration) / fade_duration)
		# Reset
		else:
			is_cloaking = false
			timer = 0.0
			modulate.a = 1.0
		
# Animation
func update_animation_parameters():
		animation.set("parameters/conditions/idle", velocity == Vector2.ZERO)
		animation.set("parameters/conditions/run", velocity != Vector2.ZERO)
		
		animation.set("parameters/Idle/blend_position", last_movement_direction)
		animation.set("parameters/Run/blend_position", last_movement_direction)
		
func start_cloaking():
	if not is_cloaking:
		is_cloaking = true
		timer = 0.0
		
func _on_cloak_cooldown_timeout() -> void:
	cloak_cooldown_ready = true
	
