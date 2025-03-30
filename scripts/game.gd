extends Node2D

var peer = ENetMultiplayerPeer.new()
var usrnm: String
@onready var username: LineEdit = $start_menu/CenterContainer/start_container/username
@export var seeker_scene: PackedScene
@export var hider_scene: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back_key") and not $start_menu.visible:
		$back_menu.visible = true
		 
	if $back_menu.visible:
		set_process_input(false)
	
func spawn_seeker(id):
	var seeker = seeker_scene.instantiate()
	seeker.name = str(id)
	call_deferred("add_child", seeker)
	
func spawn_hider(id):
	var hider = hider_scene.instantiate()
	hider.name = str(id)
	call_deferred("add_child", hider)
	
# START MENU
func _on_seeker_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	spawn_seeker(1)
	usrnm = username.text
	$start_menu.visible = false
	
func _on_hider_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	spawn_hider(1)
	usrnm = username.text
	$start_menu.visible = false
	
func _on_back_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
	
