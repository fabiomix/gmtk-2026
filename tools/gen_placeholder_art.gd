extends SceneTree
## Generates all placeholder pixel-art PNGs in res://assets/sprites/.
## Run from the project folder:
##   godot --headless --path . --script res://tools/gen_placeholder_art.gd
## then: godot --headless --path . --import

const SKIN := Color("f2c9a0")
const HAIR := Color("6b4a2b")
# Spy: black stealth suit, light outline (readable on the dark floor), green goggles.
const STEALTH := Color("15171c")
const STEALTH_PANEL := Color("2a2e36")
const OUTLINE := Color("9aa0aa")
const GOGGLES := Color("3a3f4b")
const LENS := Color("5ce07a")
const LENS_DIM := Color("3a8f50")
# Scientist: white lab coat.
const COAT := Color("e8e8e8")
const COAT_SHADE := Color("b5bac4")
const TROUSERS := Color("3a3f4b")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/sprites/items")
	_tiles()
	_player()
	_scientist()
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
	_icon()
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


## Spy in a black stealth suit with tri-lens night-vision goggles.
## 4 frames of 32x32: down | up | left | right
func _player() -> void:
	var img := Image.create(128, 32, false, Image.FORMAT_RGBA8)
	for frame in 4:
		var o := frame * 32
		img.fill_rect(Rect2i(o + 11, 3, 10, 9), STEALTH)          # head (balaclava)
		img.fill_rect(Rect2i(o + 9, 12, 14, 13), STEALTH)         # body
		img.fill_rect(Rect2i(o + 7, 13, 2, 10), STEALTH)          # left arm
		img.fill_rect(Rect2i(o + 23, 13, 2, 10), STEALTH)         # right arm
		img.fill_rect(Rect2i(o + 11, 14, 10, 3), STEALTH_PANEL)   # chest panel
		img.fill_rect(Rect2i(o + 9, 21, 14, 2), GOGGLES)          # belt
		img.fill_rect(Rect2i(o + 10, 25, 5, 6), STEALTH)          # left leg
		img.fill_rect(Rect2i(o + 17, 25, 5, 6), STEALTH)          # right leg
	# Down: goggle band with three lenses (two low, one high in the middle)
	img.fill_rect(Rect2i(11, 6, 10, 2), GOGGLES)
	img.fill_rect(Rect2i(12, 6, 2, 2), LENS)
	img.fill_rect(Rect2i(18, 6, 2, 2), LENS)
	img.fill_rect(Rect2i(15, 5, 2, 2), LENS)
	# Up: strap on the back of the head, a faint glow on the sides
	img.fill_rect(Rect2i(32 + 11, 6, 10, 1), GOGGLES)
	img.set_pixel(32 + 11, 6, LENS_DIM)
	img.set_pixel(32 + 20, 6, LENS_DIM)
	# Left: goggles sticking out of the face
	img.fill_rect(Rect2i(64 + 12, 6, 8, 1), GOGGLES)
	img.fill_rect(Rect2i(64 + 9, 5, 3, 3), GOGGLES)
	img.fill_rect(Rect2i(64 + 9, 6, 1, 2), LENS)
	# Right: mirrored
	img.fill_rect(Rect2i(96 + 12, 6, 8, 1), GOGGLES)
	img.fill_rect(Rect2i(96 + 20, 5, 3, 3), GOGGLES)
	img.fill_rect(Rect2i(96 + 22, 6, 1, 2), LENS)
	for frame in 4:
		_outline(img, Rect2i(frame * 32, 0, 32, 32), OUTLINE)
	img.save_png("res://assets/sprites/player.png")


## Scientist in a white lab coat. 4 frames of 32x32: down | up | left | right
func _scientist() -> void:
	var img := Image.create(128, 32, false, Image.FORMAT_RGBA8)
	for frame in 4:
		var o := frame * 32
		img.fill_rect(Rect2i(o + 11, 3, 10, 9), SKIN)          # head
		img.fill_rect(Rect2i(o + 11, 3, 10, 2), HAIR)          # hair
		img.fill_rect(Rect2i(o + 9, 12, 14, 15), COAT)         # coat
		img.fill_rect(Rect2i(o + 15, 12, 2, 15), COAT_SHADE)   # coat opening
		img.fill_rect(Rect2i(o + 7, 13, 2, 10), COAT)          # left arm
		img.fill_rect(Rect2i(o + 23, 13, 2, 10), COAT)         # right arm
		img.fill_rect(Rect2i(o + 10, 27, 5, 4), TROUSERS)      # left leg
		img.fill_rect(Rect2i(o + 17, 27, 5, 4), TROUSERS)      # right leg
	img.fill_rect(Rect2i(18, 15, 3, 2), Color("3a7bd5"))      # down: staff badge
	img.fill_rect(Rect2i(13, 6, 2, 2), Color.BLACK)           # down: eyes
	img.fill_rect(Rect2i(17, 6, 2, 2), Color.BLACK)
	img.fill_rect(Rect2i(32 + 11, 3, 10, 9), HAIR)            # up: back of the head
	img.fill_rect(Rect2i(32 + 15, 12, 2, 15), COAT)           # up: no opening at the back
	img.fill_rect(Rect2i(64 + 12, 6, 2, 2), Color.BLACK)      # left: one eye
	img.fill_rect(Rect2i(64 + 18, 3, 3, 9), HAIR)
	img.fill_rect(Rect2i(96 + 18, 6, 2, 2), Color.BLACK)      # right: one eye
	img.fill_rect(Rect2i(96 + 11, 3, 3, 9), HAIR)
	img.save_png("res://assets/sprites/scientist.png")


## Draws a 1-pixel outline around the opaque pixels inside rect.
func _outline(img: Image, rect: Rect2i, color: Color) -> void:
	var edge: Array[Vector2i] = []
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if img.get_pixel(x, y).a > 0.0:
				continue
			for n in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var p: Vector2i = Vector2i(x, y) + n
				if rect.has_point(p) and img.get_pixelv(p).a > 0.0:
					edge.append(Vector2i(x, y))
					break
	for p in edge:
		img.set_pixelv(p, color)


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


## Game icon: the spy's tri-lens night-vision goggles, drawn at 32x32 and
## scaled x4 without filtering (128x128, crisp pixels).
func _icon() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(1, 1, 30, 30), Color("2b2f3a"))     # background
	img.fill_rect(Rect2i(7, 4, 18, 26), STEALTH)             # balaclava
	img.fill_rect(Rect2i(5, 12, 22, 7), GOGGLES)             # goggle band
	for lens in [Rect2i(7, 13, 5, 5), Rect2i(20, 13, 5, 5), Rect2i(13, 9, 6, 6)]:
		img.fill_rect(lens.grow(1), Color("1b1e24"))          # lens rim
		img.fill_rect(lens, LENS)
		img.set_pixelv(lens.position, Color("c8ffd5"))        # glint
	_outline(img, Rect2i(1, 1, 30, 30), OUTLINE)
	img.resize(128, 128, Image.INTERPOLATE_NEAREST)
	img.save_png("res://assets/icon.png")
