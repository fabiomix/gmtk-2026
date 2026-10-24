class_name Journal
extends CanvasLayer
## The spy's journal: everything discovered in this game, by section.
## J/Tab opens it during a run and pauses the game; J/Tab/Esc close it.
## Uses _input (not _unhandled_input): Tab would otherwise be taken by the
## GUI focus navigation before reaching us.
## Process mode is Always, otherwise it couldn't react while the game is paused.

const SECTION_TITLES := {
	MemoryData.Category.NOTE: "Notes",
	MemoryData.Category.LOCK: "Locks",
	MemoryData.Category.INVESTIGATION: "Investigation",
}
const SECTION_COLOR := "#5ce07a"

@onready var _text: RichTextLabel = %Text


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed(&"journal") or event.is_action_pressed(&"pause"):
			close()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"journal") and RunManager.is_playing() and not get_tree().paused:
		open()
		get_viewport().set_input_as_handled()


func open() -> void:
	_text.text = _build_text()
	get_tree().paused = true
	show()
	_text.grab_focus()  # so the arrow keys scroll the text


func close() -> void:
	hide()
	get_tree().paused = false


func _build_text() -> String:
	var memories := GameManager.get_memories()
	if memories.is_empty():
		return "Nothing yet."
	var sections := PackedStringArray()
	for category in SECTION_TITLES:
		var entries := PackedStringArray()
		for memory in memories:
			if memory.category == category:
				entries.append("[b]%s[/b]\n%s" % [memory.title, memory.get_text()])
		if not entries.is_empty():
			sections.append("[color=%s]%s[/color]\n\n%s" % [SECTION_COLOR, SECTION_TITLES[category], "\n\n".join(entries)])
	return "\n\n\n".join(sections)
