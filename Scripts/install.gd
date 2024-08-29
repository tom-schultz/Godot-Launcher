extends Button

var _install_path : String

func setup(install_name : String, install_path : String):
	var invalid_version = not FileAccess.file_exists(install_path)
	text = install_name
	disabled = invalid_version
	_install_path = install_path

func _ready():
	pressed.connect(_launch_install)

func _launch_install():
	var result = OS.create_process(_install_path, [])
	print("Return code %d executing %s" % [result, _install_path])
