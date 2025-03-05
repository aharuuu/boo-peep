extends CharacterBody2D

@onready var animation: AnimationTree = $seeker_animtree
@onready var camera: Camera2D = $seeker_camera

var speed: float = 120.0 # Base speed
var dash_speed: float = 300.0  # Dash speed
var dash_distance_duration: float = 0.15  # How long the dash lasts

# Default variables
var input_direction = Vector2.ZERO
var is_dashing: bool = false
var dash_distance_timer: float = 0.0
var dash_cooldown_ready: float = true
var tag_cooldown_ready: float = true
var dash_direction: Vector2 = Vector2.ZERO
var last_movement_direction: Vector2 = Vector2.DOWN

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	if is_multiplayer_authority():
		camera.make_current()
	animation.active = true
	
func _process(delta):
	# Check if the dash key is not playing and on cooldown
	if Input.is_action_just_pressed("skill_key") and not is_dashing and dash_cooldown_ready:
		start_dash()
		dash_cooldown_ready = false
		$dash_timer.start()
		$seeker_ui/ui_cooldowns/ui_dash.value = 0
	
	# Check if tag key is ready
	if Input.is_action_just_pressed("tag_key") and tag_cooldown_ready:
		start_tag()
		tag_cooldown_ready = false
		$tag_timer.start()
		$seeker_ui/ui_cooldowns/ui_tag.value = 0

# Animation
func update_animation_parameters():
		animation.set("parameters/conditions/idle", velocity == Vector2.ZERO)
		animation.set("parameters/conditions/run", velocity != Vector2.ZERO)

		animation.set("parameters/Idle/blend_position", last_movement_direction)
		animation.set("parameters/Run/blend_position", last_movement_direction)
		
func _physics_process(delta):
	move_and_slide()
	update_animation_parameters()
	# Movement animation

		
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
	
	# Update last movement direction
	if input_direction != Vector2.ZERO: 
		last_movement_direction = input_direction
	
	# Dash distance
	if is_dashing:
		dash_distance_timer -= delta
		if dash_distance_timer <= 0:
			end_dash()
		velocity = dash_direction * dash_speed
	else:
		velocity = input_direction * speed
		
func start_tag():
	var tag_anim = $seeker_tag_animsprite
	tag_anim.play("tag")
	
	
func start_dash():
	# If no direction is pressed, dash forward based on the last movement direction
	dash_direction = last_movement_direction
	
	# Start the dash
	is_dashing = true
	dash_distance_timer = dash_distance_duration

func end_dash():
	is_dashing = false
	velocity = Vector2.ZERO  # Reset velocity after dash

# Dash cooldown timer
func _on_dash_timer_timeout() -> void:
	dash_cooldown_ready = true
	
# Tag cooldown timer
func _on_tag_timer_timeout() -> void:
	tag_cooldown_ready = true
