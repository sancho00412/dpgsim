extends Button

export var selectedColor = Color.red

var normalColor : Color
var selected = false
var scenarioIndex = 0

signal on_scenario_pressed(scenario_index)

func _ready():
	normalColor = $ScenarioFrame.modulate

func Select(on):
	global.game.soundManager.PlaySFX("Tick")
	selected = on
	if on:
		$ScenarioFrame.modulate = selectedColor
	else:
		$ScenarioFrame.modulate = normalColor

func _on_ScenarioOption_pressed():
	emit_signal("on_scenario_pressed", scenarioIndex)
	# get_parent().get_parent().get_parent().get_parent().SelectScenario(scenarioIndex)
	Select(true)

func InitScenarioButton(index):
	scenarioIndex = index
	var scenario = global.scenarios[index]
	$Title.text = trans.local(scenario["Title"])
	$Description.text = trans.local(scenario["Description"])
	var icon = load("res://Scenes/ScenarioSelection/SDG icons/SDG_Icon" + str(scenario["SDG"]) + ".tscn")
	$sdgIcon.add_child(icon.instance())
