extends Node2D

var max_hp: int = 100
var current_hp: int = 100

func take_damage(amount: int):
	current_hp -= amount
	$Label.text = current_hp
