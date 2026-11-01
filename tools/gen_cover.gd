extends SceneTree
## Generates the itch.io cover image (630x500) from the placeholder sprites.
## Run from the project folder:
##   godot --headless --path . --script res://tools/gen_cover.gd
## Output: itch/cover.png (the folder has a .gdignore: Godot does not import
## or export it).

const W := 630
const H := 500
const BG_SCALE := 2               # the lab is drawn at 2x, the spy at 6x
const SPY_SCALE := 6
const SPY_POS := Vector2i(219, 196)
const LENS := Color("5ce07a")
const RED_LIGHT := Color("d33a3a")
const TIMER_COLOR := Color(1, 0.35, 0.35)   # HUD low-time color
const TITLE_COLOR := Color("e8eaee")
const INK := Color("0b0c10")

# Lab background, 10x8 tiles of 32 px: W wall, . floor, C crate.
const ROOM := [
	"WWWWWWWWWW",
	"WWWWWWWWWW",
	"WWWWWWWWWW",
	"W........W",
	"W........W",
	"W........W",
	"WC......CW",
	"WWWWWWWWWW",
]

# 5x7 pixel font, only the glyphs the cover needs.
const FONT := {
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"G": ["01111", "10000", "10000", "10011", "10001", "10001", "01111"],
	"I": ["11111", "00100", "00100", "00100", "00100", "00100", "11111"],
	"J": ["00111", "00010", "00010", "00010", "00010", "10010", "01100"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"W": ["10001", "10001", "10001", "10101", "10101", "10101", "01010"],
	"0": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
	":": ["0", "1", "1", "0", "1", "1", "0"],
	" ": ["000", "000", "000", "000", "000", "000", "000"],
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://itch")
	var img := _background()
	_shadow(img, Vector2i(SPY_POS.x + 96, SPY_POS.y + 186), 70, 14)
	_spy(img)
	_text(img, "PROJECT", 3, 34, Color("9aa0aa"))
	_text(img, "GLASSWING", 8, 66, TITLE_COLOR)
	_text(img, "0:07", 6, 424, TIMER_COLOR)
	img.save_png("res://itch/cover.png")
	quit()


## The lab, drawn at 32 px per tile, darkened with a spotlight on the spy,
## then scaled 2x without filtering and cropped to the cover size.
func _background() -> Image:
	var tiles := _load("lab_tiles.png")
	var bg := Image.create(320, 256, false, Image.FORMAT_RGBA8)
	for y in ROOM.size():
		for x in ROOM[y].length():
			var atlas_x: int = {".": 0, "W": 32, "C": 64}[ROOM[y][x]]
			bg.blit_rect(tiles, Rect2i(atlas_x, 0, 32, 32), Vector2i(x * 32, y * 32))
	_sprite(bg, "door.png", 1, Vector2i(1, 2))
	_sprite(bg, "exit.png", 0, Vector2i(8, 2))
	_sprite(bg, "evacuation_plan.png", 0, Vector2i(3, 2))
	_sprite(bg, "sign.png", 0, Vector2i(6, 2))
	_sprite(bg, "cabinet.png", 0, Vector2i(1, 3))
	_sprite(bg, "filing_cabinet.png", 0, Vector2i(8, 3))
	_sprite(bg, "scientist.png", 3, Vector2i(2, 5))
	_sprite(bg, "scientist.png", 2, Vector2i(7, 4))
	_sprite(bg, "items/lab_report.png", 0, Vector2i(6, 6))

	# Darkness in a few hard steps (keeps the pixel-art look): dim lab,
	# brighter pool of light around the spy, darker corners.
	var spot := Vector2(160, 160)
	for y in bg.get_height():
		for x in bg.get_width():
			var d := Vector2(x, y).distance_to(spot)
			var light := 0.3
			if d < 50:
				light = 0.75
			elif d < 70:
				light = 0.55
			elif d > 175:
				light = 0.2
			var c := bg.get_pixel(x, y)
			bg.set_pixel(x, y, Color(c.r * light, c.g * light, c.b * light))
	# Status lights stay bright in the dark.
	bg.fill_rect(Rect2i(32 + 20, 64 + 12, 4, 4), RED_LIGHT)
	bg.fill_rect(Rect2i(256 + 10, 64 + 1, 12, 4), LENS)

	bg.resize(320 * BG_SCALE, 256 * BG_SCALE, Image.INTERPOLATE_NEAREST)
	var img := bg.get_region(Rect2i(5, 6, W, H))
	_glow(img, Vector2(2 * (32 + 22), 2 * (64 + 14) - 6), 22, RED_LIGHT, 0.5)
	_glow(img, Vector2(2 * (256 + 16), 2 * (64 + 3) - 6), 30, LENS, 0.45)
	return img


## Blits frame `frame` (32x32) of a sprite sheet onto tile `tile`.
func _sprite(dst: Image, file: String, frame: int, tile: Vector2i) -> void:
	var src := _load(file)
	dst.blend_rect(src, Rect2i(frame * 32, 0, 32, 32), tile * 32)


## Loads an imported sprite as an RGBA8 image.
func _load(file: String) -> Image:
	var img: Image = load("res://assets/sprites/" + file).get_image()
	img.convert(Image.FORMAT_RGBA8)
	return img


## The spy (facing down), scaled 6x, with glowing goggle lenses.
func _spy(img: Image) -> void:
	var spy := _load("player.png").get_region(Rect2i(0, 0, 32, 32))
	spy.resize(32 * SPY_SCALE, 32 * SPY_SCALE, Image.INTERPOLATE_NEAREST)
	img.blend_rect(spy, Rect2i(0, 0, spy.get_width(), spy.get_height()), SPY_POS)
	for lens in [Vector2(13, 7), Vector2(19, 7), Vector2(16, 6)]:
		_glow(img, Vector2(SPY_POS) + lens * SPY_SCALE, 34, LENS, 0.6)


## Soft dark ellipse under the spy's feet.
func _shadow(img: Image, center: Vector2i, rx: int, ry: int) -> void:
	for y in range(center.y - ry, center.y + ry):
		for x in range(center.x - rx, center.x + rx):
			var dx := float(x - center.x) / rx
			var dy := float(y - center.y) / ry
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, img.get_pixel(x, y).darkened(0.45))


## Additive light halo, fading out to `radius`.
func _glow(img: Image, center: Vector2, radius: float, color: Color, strength: float) -> void:
	for y in range(int(center.y - radius), int(center.y + radius) + 1):
		for x in range(int(center.x - radius), int(center.x + radius) + 1):
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
				continue
			var t := 1.0 - Vector2(x, y).distance_to(center) / radius
			if t <= 0.0:
				continue
			var c := img.get_pixel(x, y)
			var a := t * t * strength
			img.set_pixel(x, y, Color(minf(c.r + color.r * a, 1.0),
					minf(c.g + color.g * a, 1.0), minf(c.b + color.b * a, 1.0)))


## Draws centered text with the 5x7 font, `scale` px per font pixel,
## with a dark outline one font pixel wide.
func _text(img: Image, text: String, scale: int, top: int, color: Color) -> void:
	var width := 0
	for ch in text:
		width += (FONT[ch][0].length() + 1) * scale
	width -= scale
	for pass_color in [INK, color]:
		var x := (W - width) / 2
		for ch in text:
			var glyph: Array = FONT[ch]
			for gy in glyph.size():
				for gx in glyph[gy].length():
					if glyph[gy][gx] != "1":
						continue
					var r := Rect2i(x + gx * scale, top + gy * scale, scale, scale)
					if pass_color == INK:
						r = r.grow(scale)
					img.fill_rect(r, pass_color)
			x += (glyph[0].length() + 1) * scale
