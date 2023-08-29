extends Control


func _ready() -> void:
	$Discord.pressed.connect(_on_discord_button_pressed)


func _on_discord_button_pressed():
	OS.shell_open("https://discord.gg/FZY9TqW")
