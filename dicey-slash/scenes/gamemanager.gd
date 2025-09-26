extends Node

var total_coins: int = 0
var dicea = 0
var health = 100

signal coins_changed(new_total: int)

func add_coins(amount: int):
	total_coins += amount
	emit_signal("coins_changed", total_coins)
