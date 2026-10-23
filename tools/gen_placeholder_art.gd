extends SceneTree
## Generates all placeholder pixel-art PNGs in res://assets/sprites/.
## Run from the project folder:
##   godot --headless --path . --script res://tools/gen_placeholder_art.gd
## then: godot --headless --path . --import

const SKIN := Color("f2c9a0")
const HAIR := Color("4a3222")
const SUIT := Color("e07a2f")
const SUIT_DARK := Color("a85520")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/sprites/items")
	_tiles()
	_player()
	_door()
	_screwdriver()
	_security_badge()
	quit()


## Tile atlas: floor | wall | crate (32x32 each)
func _tiles() -> void:
	var img := Image.create(96, 32, false, Image.FORMAT_RGBA8)
	# Floor
	img.fill_rect(Rect2i(0, 0, 32, 32), Color("2b2f3a"))
	img.fill_rect(Rect2i(0, 0, 32, 1), Color("353a47"))
	img.fill_rect(Rect2i(0, 0, 1, 32), Color("353a47"))
	# Wall
	img.fill_rect(Rect2i(32, 0, 32, 32), Color("8a8f99"))
	img.fill_rect(Rect2i(32, 0, 32, 4), Color("b5bac4"))
	img.fill_rect(Rect2i(32, 28, 32, 4), Color("5d626b"))
	# Crate
	img.fill_rect(Rect2i(64, 0, 32, 32), Color("5a3a1c"))
	img.fill_rect(Rect2i(66, 2, 28, 28), Color("8b5a2b"))
	img.fill_rect(Rect2i(66, 15, 28, 2), Color("5a3a1c"))
	img.save_png("res://assets/sprites/lab_tiles.png")


## Spy in an orange prison jumpsuit. 4 frames of 32x32: down | up | left | right
func _player() -> void:
	var img := Image.create(128, 32, false, Image.FORMAT_RGBA8)
	for frame in 4:
		var o := frame * 32
		img.fill_rect(Rect2i(o + 11, 3, 10, 9), SKIN)        # head
		img.fill_rect(Rect2i(o + 11, 3, 10, 2), HAIR)        # hair
		img.fill_rect(Rect2i(o + 9, 12, 14, 14), SUIT)       # body
		img.fill_rect(Rect2i(o + 10, 26, 5, 5), SUIT_DARK)   # left leg
		img.fill_rect(Rect2i(o + 17, 26, 5, 5), SUIT_DARK)   # right leg
	# Down: two eyes
	img.fill_rect(Rect2i(13, 6, 2, 2), Color.BLACK)
	img.fill_rect(Rect2i(17, 6, 2, 2), Color.BLACK)
	# Up: back of the head, all hair
	img.fill_rect(Rect2i(32 + 11, 3, 10, 9), HAIR)
	# Left: one eye on the left, hair on the right
	img.fill_rect(Rect2i(64 + 12, 6, 2, 2), Color.BLACK)
	img.fill_rect(Rect2i(64 + 18, 3, 3, 9), HAIR)
	# Right: one eye on the right, hair on the left
	img.fill_rect(Rect2i(96 + 18, 6, 2, 2), Color.BLACK)
	img.fill_rect(Rect2i(96 + 11, 3, 3, 9), HAIR)
	img.save_png("res://assets/sprites/player.png")


## Door: 2 frames of 32x32: open doorway | locked steel door
func _door() -> void:
	var img := Image.create(64, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(0, 0, 32, 32), Color("5d626b"))     # frame
	img.fill_rect(Rect2i(4, 2, 24, 30), Color("0f1116"))     # dark doorway
	img.fill_rect(Rect2i(6, 28, 20, 4), Color("3a3f4b"))     # threshold
	img.fill_rect(Rect2i(32, 0, 32, 32), Color("5d626b"))    # frame
	img.fill_rect(Rect2i(36, 2, 24, 30), Color("4d5560"))    # steel door
	img.fill_rect(Rect2i(47, 2, 2, 30), Color("3a4049"))     # middle seam
	img.fill_rect(Rect2i(52, 12, 4, 4), Color("d33a3a"))     # red lock light
	img.save_png("res://assets/sprites/door.png")


func _screwdriver() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(15, 4, 2, 15), Color("c0c4cc"))     # shaft
	img.fill_rect(Rect2i(14, 4, 4, 1), Color("e8eaee"))      # flat tip
	img.fill_rect(Rect2i(12, 18, 8, 10), Color("d33a3a"))    # handle
	img.fill_rect(Rect2i(12, 21, 8, 2), Color("f2d24a"))     # handle stripe
	img.save_png("res://assets/sprites/items/screwdriver.png")


func _security_badge() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(14, 5, 4, 4), Color("5d626b"))      # clip
	img.fill_rect(Rect2i(8, 9, 16, 14), Color("e8e8e8"))     # card
	img.fill_rect(Rect2i(8, 9, 16, 3), Color("3a7bd5"))      # blue stripe
	img.fill_rect(Rect2i(10, 14, 5, 6), Color("8a8f99"))     # photo
	img.fill_rect(Rect2i(18, 15, 4, 3), Color("d9a400"))     # chip
	img.save_png("res://assets/sprites/items/security_badge.png")
