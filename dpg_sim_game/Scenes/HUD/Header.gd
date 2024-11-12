extends Node

# Dependencies
onready var date_counter = $HudLeft/DateCounter
onready var money = $MoneySystem

func Start():
	date_counter.Start()
	money.Start()

func StartProject():
	money.Spend(global.curProject["MoneyCost"])

var totalDays = 0
func CheckTime():
	totalDays += 1
	if date_counter.day == 1:
		money.Salary()
