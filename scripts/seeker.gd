extends CharacterBody2D

@onready var animation: AnimationTree = $seeker_animtree
@onready var camera: Camera2D = $seeker_camera
@onready var dust_trail = $seeker_dust_trail
@onready var ui_dash = $seeker_ui/ui_center/ui_cooldowns/ui_dash
@onready var ui_dash_timer = $seeker_ui/ui_center/ui_cooldowns/ui_dash/ui_dash_timer
@onready var ui_tag = $seeker_ui/ui_center/ui_cooldowns/ui_tag

@export var speed: float = 120.0 # Base speed
@export var dash_speed: float = 300.0  # Dash speed
@export var dash_stock: int = 2 # Dash stock

# Default variables
var input_direction = Vector2.ZERO
var last_movement_direction: Vector2 = Vector2.DOWN
# Dash variables
var dash_cooldown_ready: bool = true
var dash_stock_cooldown_ready: bool = true
var dash_direction: Vector2 = Vector2.ZERO
var is_dashing: bool = false
var dash_stock_was_0: bool = false
var dash_stock_was_2: bool = true
# Tag variables
var tag_cooldown_ready: bool = true
var is_tagging: bool = false

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	if is_multiplayer_authority():
		camera.make_current()
	animation.active = true

func _process(delta):
	# Check if dash has stock and ready and is not dashing to use
	if Input.is_action_just_pressed("skill_key") and dash_stock_cooldown_ready and dash_cooldown_ready and not is_dashing:
		start_dash()
		dash_stock -= 1
		dash_cooldown_ready = false
		$dash_cooldown.start()
		$dash_duration.start()
		ui_dash.value = 0
	
	# Check if tag is ready to use
	if Input.is_action_just_pressed("tag_key") and tag_cooldown_ready:
		start_tag()
		tag_cooldown_ready = false
		$tag_cooldown.start()
		ui_tag.value = 0
		await get_tree().create_timer(0.2).timeout
		is_tagging = true
		$tag_duration.start()
		
func _physics_process(delta):
	move_and_slide()
	update_animation_parameters()
	
	# Hide tag animation if not playing
	var tag_anim = $seeker_tag_animsprite
	if tag_anim.is_playing():
		tag_anim.visible = true
	else:
		tag_anim.visible = false
	
	# Movement
	if is_multiplayer_authority():
		input_direction = Vector2(
			Input.get_action_strength("right_key") - Input.get_action_strength("left_key"),
			Input.get_action_strength("down_key") - Input.get_action_strength("up_key")
			).normalized()
		velocity = input_direction * speed
	
	# Dust trail
	if velocity.length() > 0:
		dust_trail.emitting = true
	else:
		dust_trail.emitting = false
		
	# Update last movement direction
	if input_direction != Vector2.ZERO: 
		last_movement_direction = input_direction
		
	# Dash stock is not ready when value is 0
	if dash_stock == 0:
		dash_stock_was_0 = true
		dash_stock_cooldown_ready = false
		ui_dash.value = 0
		ui_dash_timer.stop()
	# Instantly ready when stock is 1 from 0
	if dash_stock == 1 and dash_stock_was_0:
		dash_stock_was_0 = false
		dash_cooldown_ready = true
		ui_dash.value = 1.5
		ui_dash_timer.start()
	# Dash stock cooldown starts after initial use
	if dash_stock == 1 and dash_stock_was_2:
		dash_stock_was_2 = false
		$dash_stock_cooldown.start()
	# Dash stock is ready when value is 1 or 2
	if dash_stock == 1 || dash_stock == 2:
		dash_stock_cooldown_ready = true
	# Dash stock cooldown stops when value is 2
	if dash_stock == 2:
		dash_stock_was_2 = true
		$dash_stock_cooldown.stop()
	
	# Tag area handling
	if is_tagging:
		$seeker_tag_area/seeker_tag_area_collision.disabled = false
	else:
		$seeker_tag_area/seeker_tag_area_collision.disabled = true
		
	# Dash distance
	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		velocity = input_direction * speed
		
# Animation
func update_animation_parameters():
		animation.set("parameters/conditions/idle", velocity == Vector2.ZERO)
		animation.set("parameters/conditions/run", velocity != Vector2.ZERO)
		
		animation.set("parameters/Idle/blend_position", last_movement_direction)
		animation.set("parameters/Run/blend_position", last_movement_direction)
		
func start_tag():
	var tag_anim = $seeker_tag_animsprite
	tag_anim.play("tag")
	
func start_dash():
	# If no direction is pressed, dash forward based on the last movement direction
	dash_direction = last_movement_direction
	# Start the dash
	is_dashing = true
	
func end_dash():
	is_dashing = false
	velocity = Vector2.ZERO  # Reset velocity after dash
	
func _on_dash_stock_cooldown_timeout() -> void:
	dash_stock += 1
	
func _on_dash_cooldown_timeout() -> void:
	dash_cooldown_ready = true
	
func _on_dash_duration_timeout() -> void:
	end_dash()
	
func _on_tag_cooldown_timeout() -> void:
	tag_cooldown_ready = true
	
func _on_tag_duration_timeout() -> void:
	is_tagging = false
