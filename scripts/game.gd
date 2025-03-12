extends Node2D

var peer = ENetMultiplayerPeer.new()
var host = false
var join = false
@export var seeker_scene: PackedScene
@export var hider_scene: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back_key") and not $start_menu.visible:
		$back_menu.visible = true
		 
	if $back_menu.visible:
		set_process_input(false)
	
func _play_seeker(id = 1):
	var seeker = seeker_scene.instantiate()
	seeker.name = str(id)
	call_deferred("add_child", seeker)
	
func _play_hider(id = 1):
	var hider = hider_scene.instantiate()
	hider.name = str(id)
	call_deferred("add_child", hider)
	
# START MENU
func _on_host_button_pressed() -> void:
	host = true
	$start_menu.visible = false
	$choose_menu.visible = true

func _on_join_button_pressed() -> void:
	join = true
	$start_menu.visible = false
	$choose_menu.visible = true
	
func _on_back_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
	
# CHOOSE MENU
func _on_seeker_button_pressed() -> void:
	if host:
		peer.create_server(135)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_play_seeker)
	if join:
		peer.create_client("localhost", 135)
		multiplayer.multiplayer_peer = peer
	_play_seeker()
	$choose_menu.visible = false
	
func _on_hider_button_pressed() -> void:
	pass
	if host:
		peer.create_server(135)
		multiplayer.multiplayer_peer = peer
	if join:
		peer.create_client("localhost", 135)
		multiplayer.multiplayer_peer = peer
	_play_hider()
	$choose_menu.visible = false
	
func _on_back_button_choose_pressed() -> void:
	host = false
	join = false
	$start_menu.visible = true
	$choose_menu.visible = false
