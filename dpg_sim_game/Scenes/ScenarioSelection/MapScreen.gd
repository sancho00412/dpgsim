extends Node

var scenarioPrefab = preload("res://Scenes/ScenarioSelection/ScenarioOption.tscn")

# Dependencies
onready var buttonsParent = $CenterContainer/ScenarioList/ScrollContainer/VBoxContainer
onready var backButton = $CenterContainer/ScenarioList/Back_Button
onready var startButton = $CenterContainer/ScenarioList/Start_Button
onready var map = $CenterContainer/MapSprite
onready var scenario_list = $CenterContainer/ScenarioList
onready var scenario_list_scroll = $CenterContainer/ScenarioList/ScrollContainer
onready var map_regions = $CenterContainer/MapSprite/Control.get_children()

var buttonsList = []

func Start():
	backButton.Start()
	startButton.Start()
	_on_Back_Button_buttonPressed()
	for regionInd in range(7):
		for i in range(global.scenarios.size()):
			if (global.scenarios[i]["MapRegion"] == regionInd):
				global.regionsActive[regionInd] = true
				map_regions[regionInd].connect("on_map_region_pressed", self, "OpenScenarioList")
				break
	global.game.gameTooltip.SetTooltip(trans.local("MAP_POPUP_TITLE"), trans.local("MAP_POPUP_DESC"), null)

func OpenScenarioList(region):
	map.visible = false
	scenario_list.visible = true
	for i in range(global.scenarios.size()):
		if (global.scenarios[i]["MapRegion"] == region):
			var newButton = scenarioPrefab.instance()
			buttonsParent.add_child(newButton)
			newButton.InitScenarioButton(i)
			buttonsList.append(newButton)
			newButton.connect("on_scenario_pressed", self, "SelectScenario")

func SelectScenario(var scenarioIndex):
	global.activeScenarioIndex = scenarioIndex
	startButton.visible = true
	for button in buttonsList:
		button.Select(false)



func _on_Back_Button_buttonPressed():
	map.visible = true
	scenario_list.visible = false
	startButton.visible = false
	scenario_list_scroll.scroll_vertical = 0
	for i in range(buttonsParent.get_child_count()):
		buttonsParent.get_child(i).disconnect("on_scenario_pressed", self, "SelectScenario")
		buttonsParent.get_child(i).queue_free()
		buttonsList.clear()

func _on_Start_Button_buttonPressed():
	var desc = trans.local(global.curScenario()["Description"]) + "\n\n"
	desc += trans.local("BUDGET") + ": " + str(global.curScenario()["Money"])
	var callback = funcref(global.game, "StartScenario")
	global.game.gameTooltip.SetTooltip(trans.local(global.curScenario()["Title"]), desc, callback)
