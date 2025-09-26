extends Node

var total_coins: int = 0
var owned_abilities: Array[String] = [] # Stores the 'id' of owned abilities
var dicea = 0
var health = 100

signal coins_changed(new_total: int)

func add_coins(amount: int):
	total_coins += amount
	emit_signal("coins_changed", total_coins)

func is_ability_owned(ability_id: String) -> bool:
	return ability_id in owned_abilities
