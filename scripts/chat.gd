extends Control

@onready var host: Button = $host
@onready var join: Button = $join
@onready var username: LineEdit = $username
@onready var message: LineEdit = $message
@onready var send: Button = $send
@onready var messages: TextEdit = $messages

var usrnm: String
var msg: String

func _on_host_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()
	
func _on_join_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 1027)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()
	
func _on_send_pressed() -> void:
	rpc("msg_rpc", usrnm, message.text)
	message.clear()
	
@rpc ("any_peer", "call_local")
func msg_rpc(usrnm,data):
	messages.text += str(usrnm, ": ", data, "\n")
	messages.scroll_vertical = messages.get_line_count()
	
func joined():
	host.hide()
	join.hide()
	username.hide()
	message.visible = true
	send.visible = true
	messages.visible = true
	usrnm = username.text
