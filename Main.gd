extends Control

const PORT = 3000
const MAX_USER = 4
var oldname:String = ""
var username
var id
onready var chat_display = $RoomUI/ChatDisplay
onready var chat_input = $RoomUI/ChatInput

onready var user_name = $SetUp/name


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("connected_to_server", self, "enter_room")
	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func _server_disconnected():
	chat_display.text += 'Disconnected from Server.\n'
	_on_LeaveBtn_pressed()

func user_entered(id):
	chat_display.text += str(id) + " joined the room"

func user_exited(id):
	chat_display.text += str(id) + " left the room"
	
func enter_room():
	chat_display.text = "Successfully joined room\n"
	$SetUp/LeaveBtn.show()
	$SetUp/JoinBtn.hide()
	$SetUp/HostBtn.hide()
	$SetUp/Ip.hide()
	
func _on_LeaveBtn_pressed():
	get_tree().set_network_peer(null)
	chat_display.text += 'You left the room.\n'
	OS.set_window_title('You left the room')
	$SetUp/LeaveBtn.hide()
	$SetUp/JoinBtn.show()
	$SetUp/HostBtn.show()
	$SetUp/Ip.show()

func _on_JoinBtn_pressed():
	var ip = $SetUp/Ip.text
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)
	OS.set_window_title("Chat Room - Client")

func _on_HostBtn_pressed():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_USER)
	get_tree().set_network_peer(host)
	enter_room()
	chat_display.text = "Room Created\n"
	OS.set_window_title("Chat Room - Host")

func _on_NameBtn_pressed():
	if oldname == str(get_tree().get_network_unique_id()):
		pass
	username = user_name.text
	if oldname == '':
		oldname = username
	oldname = str(id)
	id = username
	user_name.text = ""
	rpc("changing_name", oldname, id)
	
sync func changing_name(oldname, id):
	chat_display.text += oldname + " changed to " + str(id) + "\n"

func _on_ChatInput_text_entered(new_text):
	send_message()
	
func send_message():
	var msg = chat_input.text
	chat_input.text = ''
	if username == null:
		id = get_tree().get_network_unique_id()
		print(id)
		oldname = str(id)
	rpc("receive_message", id, msg)
	
sync func receive_message(id, msg):
	chat_display.text += str(id) + ":" + msg + "\n"
	
