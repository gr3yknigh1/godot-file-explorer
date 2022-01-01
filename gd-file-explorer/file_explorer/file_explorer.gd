extends Control


const FOLDER_ICON: Texture = preload("res://file_explorer/icons/folder.svg")
const FILE_ICON: Texture = preload("res://file_explorer/icons/file.svg")


class ConfigManager:
	
	const DEFAULT_CONFIG_FILENAME = "default_config.txt"
	var DEFAULT_CONFIG_PATH: String = OS.get_user_data_dir().plus_file(DEFAULT_CONFIG_FILENAME)
	const DEFAULT_CONFIG = {
		"starting_dir": "C:/",
		"view_hidden_items": false
	}

	const USER_CONFIG_FILENAME = "user_config.txt"
	var USER_CONFIG_PATH: String = OS.get_user_data_dir().plus_file(USER_CONFIG_FILENAME)
	var user_config : Dictionary = {}


	func _load_user_config() -> void:
		var file = File.new()
		
		if not file.file_exists(USER_CONFIG_PATH):
			file.open(USER_CONFIG_PATH, File.Write)
			file.store_string(var2str(user_config))
		else:
			file.open(USER_CONFIG_PATH, File.READ)
			var user_config_str = file.get_as_text()
			if user_config_str != "":
				user_config = str2var(user_config_str)

		file.close()
	
	func _override_default_config() -> void:
		var file := File.new()
		
		if file.open(DEFAULT_CONFIG_PATH, File.WRITE) != OK:
			push_error("Error while openning default config file")
		
		var default_config_str := var2str(DEFAULT_CONFIG)
		file.store_string(default_config_str)
		
		file.close()

	func _init() -> void:
		self._override_default_config()
		self._load_user_config()

	func get(name: String):
		var config_var = user_config.get(
			name, DEFAULT_CONFIG.get(name, null)
		)
		
		if config_var == null:
			push_error("Config var doesn't exists %s" % name)
		return config_var
	
	func set(name: String, value) -> void:
		user_config[name] = value


onready var content_list := $VBoxContainer/ContentList
onready var config := ConfigManager.new()
onready var current_path: String


func get_dir_content(path: String) -> Array:
	var path_content = []
	var dir = Directory.new()
	
	assert (dir.open(path) == OK, "Error while openning path")
	
	dir.list_dir_begin()
	var item_name = dir.get_next()
	while item_name != "":
		path_content.append(item_name)
		item_name = dir.get_next()
	return path_content


func update_content_list() -> void:
	content_list.clear()
	
	var dir = Directory.new()
	
	assert (dir.open(current_path) == OK, "Error while openning path")
	
	dir.list_dir_begin(false, not config.get("view_hidden_items"))
	var item_name = dir.get_next()
	while item_name != "":
		
		content_list.add_item(
			item_name,
			FOLDER_ICON if dir.current_is_dir() else FILE_ICON
		)
		
		item_name = dir.get_next()


func change_current_directory(dir_path: String) -> void:
	match dir_path:
		".":
			pass
		"..":
			current_path = current_path.get_base_dir()
		_:
			if dir_path.is_rel_path():
				dir_path = current_path.plus_file(dir_path)
			
			var dir := Directory.new()
			
			if dir.open(dir_path) != OK:
				print("Can't open as directory: '%s'" % dir_path)
				return
			current_path = dir_path
	update_content_list()


func _ready() -> void:
	change_current_directory(config.get("starting_dir"))
	$VBoxContainer/HiddenItems.pressed = config.get("view_hidden_items")


func _on_ContentList_item_activated(index: int) -> void:
	var item_text: String = content_list.get_item_text(index)
	change_current_directory(item_text)


func _on_HiddenItems_toggled(button_pressed):
	config.set("view_hidden_items", button_pressed)
	update_content_list()
