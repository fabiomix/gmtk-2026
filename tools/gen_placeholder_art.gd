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
	_lab_report()
	_cabinet()
	_filing_cabinet()
	_exit()
	_scratches()
	_sign()
	_evacuation_plan()
	_clipboard()
	_memo()
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


func _lab_report() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(8, 6, 16, 21), Color("c9a86a"))    # folder
	img.fill_rect(Rect2i(8, 4, 7, 3), Color("c9a86a"))      # folder tab
	img.fill_rect(Rect2i(10, 9, 12, 15), Color("f2efe6"))   # paper
	img.fill_rect(Rect2i(10, 12, 12, 3), Color("d33a3a"))   # "TOP SECRET" stripe
	for y in [17, 19, 21]:
		img.fill_rect(Rect2i(11, y, 10, 1), Color("8a8f99")) # text lines
	img.save_png("res://assets/sprites/items/lab_report.png")


## Metal cabinet, 2 frames: closed (screwed shut) | open (empty inside)
func _cabinet() -> void:
	var img := Image.create(64, 32, false, Image.FORMAT_RGBA8)
	for frame in 2:
		var o := frame * 32
		img.fill_rect(Rect2i(o + 4, 2, 24, 29), Color("5d626b"))  # body
		img.fill_rect(Rect2i(o + 6, 4, 20, 25), Color("7d8590"))  # door
	for p in [Vector2i(7, 5), Vector2i(23, 5), Vector2i(7, 26), Vector2i(23, 26)]:
		img.fill_rect(Rect2i(p, Vector2i(2, 2)), Color("d9d9d9"))  # screws
	img.fill_rect(Rect2i(32 + 6, 4, 20, 25), Color("1b1e24"))     # open: dark inside
	img.fill_rect(Rect2i(32 + 6, 16, 20, 1), Color("3a3f4b"))     # open: shelf
	img.save_png("res://assets/sprites/cabinet.png")


## Filing cabinet, 2 frames: closed (keyhole) | open (top drawer pulled out)
func _filing_cabinet() -> void:
	var img := Image.create(64, 32, false, Image.FORMAT_RGBA8)
	for frame in 2:
		var o := frame * 32
		img.fill_rect(Rect2i(o + 6, 2, 20, 29), Color("6b5a45"))  # body
		for y in [4, 13, 22]:
			img.fill_rect(Rect2i(o + 8, y, 16, 7), Color("8c7658"))   # drawers
			img.fill_rect(Rect2i(o + 13, y + 3, 6, 1), Color("3a3026"))  # handles
	img.fill_rect(Rect2i(15, 2, 2, 2), Color("d9a400"))            # closed: keyhole
	img.fill_rect(Rect2i(32 + 8, 4, 16, 7), Color("1b1e24"))       # open: empty drawer
	img.save_png("res://assets/sprites/filing_cabinet.png")


## Exit door in the wall: frame + green "exit" light + arrow
func _exit() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(0, 0, 32, 32), Color("5d626b"))      # frame
	img.fill_rect(Rect2i(4, 6, 24, 26), Color("2f6b3a"))      # green door
	img.fill_rect(Rect2i(10, 1, 12, 4), Color("5ce07a"))      # exit light
	img.fill_rect(Rect2i(9, 17, 12, 3), Color("e8e8e8"))      # arrow shaft
	img.fill_rect(Rect2i(19, 14, 2, 9), Color("e8e8e8"))      # arrow head
	img.fill_rect(Rect2i(21, 16, 2, 5), Color("e8e8e8"))
	img.fill_rect(Rect2i(23, 18, 1, 1), Color("e8e8e8"))
	img.save_png("res://assets/sprites/exit.png")


## Notes are drawn on top of a wall or furniture tile (transparent background).

## Tally marks and a scratched line of "text" on the cell wall.
func _scratches() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var scratch := Color("d5dae2")
	for x in [8, 11, 14, 17]:
		img.fill_rect(Rect2i(x, 8, 1, 9), scratch)              # tally marks
	for i in 12:
		img.set_pixel(6 + i, 15 - i / 2, scratch)                # diagonal stroke
	for x in [6, 10, 13, 18, 21, 24]:
		img.fill_rect(Rect2i(x, 21, 2, 1), scratch)              # scratched words
	img.save_png("res://assets/sprites/scratches.png")


## Blue direction sign with white lines of text.
func _sign() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(4, 8, 24, 14), Color("2d5fa8"))
	img.fill_rect(Rect2i(5, 9, 22, 12), Color("3a74c4"))
	for y in [11, 14, 17]:
		img.fill_rect(Rect2i(8, y, 16, 1), Color("e8e8e8"))
	img.save_png("res://assets/sprites/sign.png")


## Evacuation plan: white sheet, green border, a tiny map with a red dot.
func _evacuation_plan() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(5, 5, 22, 20), Color("2f9e4f"))
	img.fill_rect(Rect2i(6, 6, 20, 18), Color("f2efe6"))
	for r in [Rect2i(8, 8, 5, 4), Rect2i(14, 8, 9, 4), Rect2i(8, 14, 15, 3), Rect2i(8, 18, 6, 4)]:
		img.fill_rect(r, Color("8a8f99"))
	img.fill_rect(Rect2i(21, 18, 2, 2), Color("d33a3a"))    # "you are here"
	img.save_png("res://assets/sprites/evacuation_plan.png")


## Guard log: clipboard with a sheet of paper.
func _clipboard() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(9, 6, 14, 21), Color("7a5a3a"))     # board
	img.fill_rect(Rect2i(11, 9, 10, 16), Color("f2efe6"))    # paper
	img.fill_rect(Rect2i(13, 4, 6, 3), Color("b5bac4"))      # clip
	for y in [12, 15, 18, 21]:
		img.fill_rect(Rect2i(12, y, 8, 1), Color("8a8f99"))
	img.save_png("res://assets/sprites/clipboard.png")


## Internal memo: a sheet with a red stamp.
func _memo() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(10, 6, 12, 18), Color("f2efe6"))
	img.fill_rect(Rect2i(12, 8, 5, 3), Color("d33a3a"))      # stamp
	for y in [13, 16, 19]:
		img.fill_rect(Rect2i(12, y, 8, 1), Color("8a8f99"))
	img.save_png("res://assets/sprites/memo.png")
