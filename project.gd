extends PanelContainer

var _install_path : String
var _project_path : String
var _godot_version : String

func setup(project_name : String, godot_version : String, install_path : String, project_path : String):
		%ProjectLabel.text = project_name
		%VersionLabel.text = godot_version if godot_version else "MISSING"
		%LaunchButton.disabled = godot_version == null or not FileAccess.file_exists(install_path)
		_install_path = install_path
		_project_path = project_path

func _ready():
	%LaunchButton.pressed.connect(_launch_project)

func _launch_project():
	var output : Array
	var result = OS.create_process(_install_path, ["--editor", "--path", _project_path])
	print(output)
