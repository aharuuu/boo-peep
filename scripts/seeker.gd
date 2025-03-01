extends CharacterBody2D

var speed: float = 120.0 # Base speexzd
var dash_speed: float = 240.0  # Dash speexd
var dash_duration: float = 0.15  # How long the dash lasts
var dash_cooldown: float = 1.0  # Cooldown between zzzzdashes
var tag_cooldown: float = 2 # Cooldown between tagsz

# Default variables
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var tag_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var last_movement_direction: Vector2 = Vector2.DOWN

func _process(delta):
	# Dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	# Tag cooldown
	if tag_cooldown_timer > 0:
		tag_cooldown_timer -= delta

	# Check if the dash key is not playing and on cooldown
	if Input.is_action_just_pressed("skill_key") and not is_dashing and dash_cooldown_timer <= 0:
		start_dash()
	
	# Check if the tag key is not on cooldown
	if Input.is_action_just_pressed("tag_key") and tag_cooldown_timer <= 0:
		start_tag()
		
func _physics_process(delta):
	move_and_slide()
	
	# Movement animation
	var anim = $seeker_animation
	var tag_anim = $tag_animation
	if Input.is_action_pressed("down_key"):
		anim.play("run_down")
	elif Input.is_action_pressed("down_key") and Input.is_action_pressed("left_key"):
		anim.play("run_down")
	elif Input.is_action_pressed("down_key") and Input.is_action_pressed("right_key"):
		anim.play("run_down")
	elif Input.is_action_pressed("up_key"):
		anim.play("run_up")
	elif Input.is_action_pressed("up_key") and Input.is_action_pressed("left_key"):
		anim.play("run_up")
	elif Input.is_action_pressed("up_key") and Input.is_action_pressed("right_key"):
		anim.play("run_up")
	elif Input.is_action_pressed("left_key"):
		anim.flip_h = true
		anim.play("run_side")
	elif Input.is_action_pressed("right_key"):
		anim.flip_h = false
		anim.play("run_side")
	else:
		if last_movement_direction.y < 0:
			anim.play("idle_up")
		elif last_movement_direction.y > 0:
			anim.play("idle_down")
		elif last_movement_direction.x < 0:
			anim.flip_h = true
			anim.play("idle_side")
		elif last_movement_direction.x > 0:
			anim.flip_h = false
			anim.play("idle_side")
		
	# Hide tag animation if not playing
	if tag_anim.is_playing():
		tag_anim.visible = true
	else:
		tag_anim.visible = false
	
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right_key") - Input.get_action_strength("left_key"),
		Input.get_action_strength("down_key") - Input.get_action_strength("up_key")
	).normalized()
	velocity = input_direction * speed
	
	# Update last movement direction
	if input_direction != Vector2.ZERO:
		last_movement_direction = input_direction
		
	# Dash distance
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			end_dash()
		velocity = dash_direction * dash_speed
	else:
		velocity = input_direction * speed
		
func start_tag():
	var tag_anim = $tag_animation
	tag_anim.play("tag")
	
	tag_cooldown_timer = tag_cooldown
	
func start_dash():
	# If no direction is pressed, dash forward based on the last movement direction
	dash_direction = last_movement_direction
	
	# Start the dash
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

func end_dash():
	is_dashing = false
	velocity = Vector2.ZERO  # Reset velocity after dash
