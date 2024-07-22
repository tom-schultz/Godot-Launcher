extends Control

var _project_scene : PackedScene = preload("res://project.tscn")
var _install_dir : String = "installs"
const INSTALL_DIR_KEY : String = "install_dir"
var _project_dir : String = "projects"
const PROJECT_DIR_KEY : String = "project_dir"

# Called when the node enters the scene tree for the first time.
func _ready():
	var exe_path : String = OS.get_executable_path()
	var exe_dir : String = exe_path.left(exe_path.rfind("/") + 1)
	
	if LocalDB.has_key(INSTALL_DIR_KEY):
		_install_dir = LocalDB.read_key(INSTALL_DIR_KEY)
	else:
		_install_dir = exe_dir + _install_dir
	
	if LocalDB.has_key(PROJECT_DIR_KEY):
		_project_dir = LocalDB.read_key(PROJECT_DIR_KEY)
	else:
		_project_dir = exe_dir + _project_dir

	%InstallDirLabel.text = _install_dir
	%InstallDirButton.pressed.connect(_open_install_dir)
	%InstallDirectoryDialog.dir_selected.connect(_on_install_dir_selected)
	
	%ProjectDirLabel.text = _project_dir
	%ProjectDirButton.pressed.connect(_open_project_dir)
	%ProjectDirectoryDialog.dir_selected.connect(_on_project_dir_selected)
	
	for project in DirAccess.get_directories_at(_project_dir):
		var project_path : String = "%s/%s" % [_project_dir, project]
		var project_file_path : String = project_path + "/project.godot"
		var lock_path : String = project_path + "/godot-version.lock"
		var godot_version = null
		var maj_minor = _get_maj_minor(project_file_path)
		
		if not FileAccess.file_exists(project_file_path):
			continue

		if FileAccess.file_exists(lock_path):
			godot_version = FileAccess.get_file_as_string(lock_path)
		else:
			godot_version = _build_lock(lock_path, project_path, maj_minor)
		
		var new_project = _project_scene.instantiate()
		new_project.setup(project, godot_version, "%s/%s" % [_install_dir, godot_version], project_path)
		%ProjectContainer.add_child(new_project)

func _open_project_dir():
	%ProjectDirectoryDialog.current_dir = _project_dir
	%ProjectDirectoryDialog.popup_centered_ratio()

func _open_install_dir():
	%InstallDirectoryDialog.current_dir = _install_dir
	%InstallDirectoryDialog.popup_centered_ratio()

func _on_project_dir_selected(dir):
	%ProjectDirLabel.text = dir
	_project_dir = dir
	LocalDB.write_key(PROJECT_DIR_KEY, dir)

func _on_install_dir_selected(dir):
	%InstallDirLabel.text = dir
	_project_dir = dir
	LocalDB.write_key(INSTALL_DIR_KEY, dir)

func _build_lock(lock_path : String, project_dir: String, maj_minor : String):
	var csharp = false
	
	for file in DirAccess.get_files_at(project_dir):
		if file.ends_with(".sln"):
			csharp = true
			break
	
	var versions = DirAccess.get_files_at(_install_dir)
	versions.sort()
	versions.reverse()

	for version in versions:
		if not version.ends_with(".exe"):
			continue

		if version.contains(maj_minor) and (not csharp or version.contains("mono")):
			print("Locking %s at version %s." % [project_dir, version])
			var file = FileAccess.open(lock_path, FileAccess.WRITE)
			file.store_string(version)
			file.close()
			return version

	return null

func _get_maj_minor(project_file_path):
	var config_file = ConfigFile.new()

	if OK != config_file.load(project_file_path):
		print("Woops, couldn't find project file!")
		return

	var features = config_file.get_value("application", "config/features")
	var maj_minor_ver = null

	for feature in features:
		if feature.begins_with("4.") or feature.begins_with("3."):
			maj_minor_ver = feature
			break
	
	return maj_minor_ver
