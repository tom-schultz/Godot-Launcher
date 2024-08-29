extends Button

const DOWNLOAD_FORMAT_STRING : String = "https://github.com/godotengine/godot/releases/download/%s/%s.zip"

var _install_path : String
var _project_path : String
var _godot_version : String

func setup(project_name : String, godot_version : String, install_path : String, project_path : String):
	_godot_version = godot_version
	var invalid_version = godot_version == null or not FileAccess.file_exists(install_path)
	text = project_name
	%ProjectLabel.text = project_name
	%VersionLabel.add_theme_color_override("font_color", Color.LIGHT_CORAL if invalid_version else Color.WHITE)
	%VersionLabel.text = godot_version
	disabled = invalid_version
	%VersionDownloadButton.visible = invalid_version
	_install_path = install_path
	_project_path = project_path

func _ready():
	pressed.connect(_launch_project)
	%VersionDownloadButton.pressed.connect(_on_download_pressed)

func _launch_project():
	var result = OS.create_process(_install_path, ["--editor", "--path", _project_path])
	print("Return code %d executing %s for %s" % [result, _install_path, _project_path])

func _on_download_pressed():
	var version_base = _godot_version.trim_prefix("Godot_v")
	version_base = version_base.left(version_base.find("_"))
	print(version_base)
	OS.shell_open(DOWNLOAD_FORMAT_STRING % [version_base, _godot_version])
