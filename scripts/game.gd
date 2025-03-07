extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back_key") and not $start_menu.visible:
		$back_menu.visible = true
		 
	if $back_menu.visible:
		$".".set_process_input(false)
		
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
		
		
func _on_host_button_pressed() -> void:
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	$start_menu.visible = false
	
func _on_join_button_pressed() -> void:
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
	$start_menu.visible = false

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
