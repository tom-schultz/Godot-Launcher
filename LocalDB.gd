extends Node
class_name LocalDB

const DB_PATH : String = "user://local_db.json"

static var _data : Dictionary

static func delete_key(key: String):
	_data.erase(key)
	_write_save()

static func has_key(key: String):
	return _data.has(key)

static func read_key(key: String):
	return _data[key] if _data.has(key) else null

static func write_key(key: String, value):
	_data[key] = value
	_write_save()

static func _static_init():
	assert(DB_PATH.is_absolute_path())

	if not FileAccess.file_exists(DB_PATH):
		_data = Dictionary()
		return

	var db_file = FileAccess.open(DB_PATH, FileAccess.READ)
	_data = JSON.parse_string(db_file.get_as_text())
	assert(_data != null, "Couldn't load file: %s" % db_file.get_path_absolute())

static func _write_save():
	var json = JSON.stringify(_data)

	assert(json != null,
			"Could not serialize _data to JSON!\n_data: %s" \
			% [_data])

	var db_file = FileAccess.open(DB_PATH, FileAccess.WRITE)
	db_file.store_string(json)
