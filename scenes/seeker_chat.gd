extends CanvasLayer

@onready var game = get_node("/root/game")
@onready var message: LineEdit = $message
@onready var messages: TextEdit = $messages

@onready var usrnm: String = game.usrnm
var msg: String

func _on_send_pressed() -> void:
	rpc("msg_rpc", usrnm, message.text)
	message.clear()
	
@rpc ("any_peer", "call_local")
func msg_rpc(usrnm,data):
	messages.text += str(usrnm, ": ", data, "\n")
	messages.scroll_vertical = messages.get_line_count()
