# StoreItem.gd (Extend Resource for data)
extends Resource
class_name StoreItem

# Use @export to make these visible and editable in the Inspector when creating .tres files
@export var id: String = ""
@export var item_name: String = "New Ability"
@export var description: String = "Grants the player a cool new power."
@export var cost: int = 100
@export var is_permanent_upgrade: bool = true
@export var effect_data: Dictionary = {} # For specific stats/values (e.g., {"damage_multiplier": 1.5})
# @export var icon: Texture2D # Optional: for an icon image

# Save instances of this resource (e.g., "DoubleJump.tres", "SpeedBoost.tres")
# by right-clicking in the FileSystem -> New -> Resource -> StoreItem