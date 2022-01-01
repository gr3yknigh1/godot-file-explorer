extends Node2D


func get_path_content(path: String) -> Array:
	var path_content = []
	var dir = Directory.new()
	
	assert (dir.open(path) == OK, "Error while openning path")
	
	dir.list_dir_begin(true, true)
	var item_name = dir.get_next()
	while item_name != "":
		path_content.append(item_name)
		item_name = dir.get_next()
		
	return path_content


func _ready() -> void:
	for i in get_path_content("C:\\"):
		print(i)
