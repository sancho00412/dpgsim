extends Node

var rng = RandomNumberGenerator.new()
func _ready():
	rng.randomize()

# Dependencies
onready var counters = {
	"Fit": $CenterContainerTop/Control/FitCounter, 
	"Dev": $CenterContainerTop/Control/DevCounter, 
	"Market": $CenterContainerTop/Control/MarketCounter
}
onready var office = $CenterContainerMiddle/Control/Office
onready var team_button = $CenterContainerMiddle/Control/Team_Button
onready var actions_button = $CenterContainerMiddle/Control/Actions_Button
onready var project_button = $CenterContainerMiddle/Control/Project_Button
onready var project_progress = $CenterContainerMiddle/Control/ProjectProgress
onready var project_progress_label = $CenterContainerMiddle/Control/ProjectProgress/ProjectProgressLabel
onready var action_progress = $CenterContainerMiddle/Control/ActionProgress
onready var action_progress_label = $CenterContainerMiddle/Control/ActionProgress/ActionProgressLabel

var PGR = 0.0
var NPR = 0.0
var PGR_limit = 0.0
var NPR_limit = 0.0
func Start():
	office.Start()
	team_button.Start()
	actions_button.Start()
	project_button.Start()
	project_button.StartShaking()
	
	counters["Fit"].LocalizeText("FIT_PTS")
	counters["Dev"].LocalizeText("DEV_PTS")
	counters["Market"].LocalizeText("MARKET_PTS")
	
	PGR = float(global.mainConfig["PGR"])
	NPR = float(global.mainConfig["NPR"])
	PGR_limit = float(global.mainConfig["PGR_limit"])
	NPR_limit = float(global.mainConfig["NPR_limit"])

func FirstStart():
	team_button.visible = false
	project_progress.visible = false
	actions_button.visible = false
	project_button.visible = true
	office.ResetOffice()

func StartProject():
	team_button.visible = global.curPhaseIndex > 1
	if global.curPhaseIndex == 2:
		global.game.PauseTimer(true)
		global.game.gameTooltip.closeIsProceed = true
		global.game.gameTooltip.SetTooltip(
			trans.local("TEAM_POPUP_TITLE"),
			trans.local("TEAM_POPUP_DESC"),
			funcref(self, "Unpause"))
		team_button.StartShaking()
		team_button.stopShakingOnPress = true
	
	actions_button.visible = global.curPhaseIndex > 2
	if global.curPhaseIndex == 3:
		global.game.PauseTimer(true)
		global.game.gameTooltip.closeIsProceed = true
		global.game.gameTooltip.SetTooltip(
			trans.local("ACTIONS_POPUP_TITLE"),
			trans.local("ACTIONS_POPUP_DESC"),
			funcref(self, "Unpause"))
		actions_button.StartShaking()
		actions_button.stopShakingOnPress = true
	
	project_button.visible = false
	project_progress.visible = true
	curDays = 0
	SetProjectProgress()
	office.StartProject()
	counters["Fit"].present = global.mainConfig["Phases"][global.curPhaseIndex]["Fit"]
	counters["Dev"].present = global.mainConfig["Phases"][global.curPhaseIndex]["Dev"]
	counters["Market"].present = global.mainConfig["Phases"][global.curPhaseIndex]["Market"]
	for counter in counters.values():
		counter.Start()

func GenPoints():
	for i in range(counters.size()):
		if counters.values()[i].present:
			if global.actionsActive[i]:
				if counters.values()[i].bad > 0:
					CleanNegativePoint(counters.values()[i], i)
			else:
				GenOnePoint(counters.values()[i], i)

func GenOnePoint(counter : PointCounter, ind : int):
	var pBonus : float = global.GetInsight(ind, true)
	var nBonus : float = global.GetInsight(ind, false)
	
	var remainder = PGR + pBonus
	var negChance = clamp(NPR + nBonus, 0, NPR_limit)
	while remainder > 0:
		var pointChance = rng.randf_range(1, 100)
		var temp_PGR = clamp(remainder, 0, PGR_limit)
		#print(counter.name, " | random number:", pointChance, " PGR:", remainder, " clamped PGR: ", temp_PGR)
		if pointChance <= temp_PGR:
			remainder -= temp_PGR
			var negRandom = rng.randf_range(1, 100)
			var isGood = negRandom > negChance
			#print("NPR:", NPR + nBonus, " clamped NPR:", negChance, " random number:", negRandom)
			office.EnqueuePoint(counter, isGood)
		else:
			remainder = 0

func CleanNegativePoint(counter : PointCounter, ind : int):
	var remainder = PGR
	while remainder > 0:
		var pointChance = rng.randf_range(1, 100)
		var temp_PGR = clamp(remainder, 0, PGR_limit)
		#print(counter.name, " | random number:", pointChance, " PGR:", remainder, " clamped PGR: ", temp_PGR)
		if pointChance <= temp_PGR:
			remainder -= temp_PGR
			office.EnqueueClean(counter)
		else:
			remainder = 0

func ResetCounters():
	for counter in counters.values():
		counter.Reset()

func SetProjectProgress():
	project_progress.value = float(curDays) / float(global.curProject["TimeCost"]) * 100.0
	project_progress_label.text = str(curDays) + "/" + global.curProject["TimeCost"]
	if curDays == int(global.curProject["TimeCost"]):
		project_progress.visible = false
		project_button.visible = true

func SetActionProgress(i):
	action_progress.value = float(actionDays) / float(global.actions[i]["TimeCost"]) * 100.0
	action_progress_label.text = str(actionDays) + "/" + str(global.actions[i]["TimeCost"])
	if actionDays == int(global.actions[i]["TimeCost"]):
		global.actionsActive[0] = false
		global.actionsActive[1] = false
		global.actionsActive[2] = false
		actionDays = 0
		action_progress.visible = false
		actions_button.visible = true
		project_button.visible = curDays >= int(global.curProject["TimeCost"])

var curDays = 0
var actionDays = 0
var curAction
func CheckTime():
	GenPoints()
	var index = -1
	for i in range(3):
		if global.actionsActive[i]:
			if index < 0:
				index = i
			else:
				index = -2
				break
	if index == -1: # no actions are active
			curDays += 1
			global.game.CheckEvents(curDays)
			if curDays == int(global.curProject["TimeCost"]):
				global.game.Overtime()
			SetProjectProgress()
	else:
		if index < 0: # all actions are active
			index = 3
		action_progress.visible = true
		actions_button.visible = false
		project_button.visible = false
		actionDays += 1
		SetActionProgress(index)


func _on_Team_Button_buttonPressed():
	global.game.OpenTeamScreen(true)

func _on_Actions_Button_buttonPressed():
	global.game.OpenActionScreen(true)

func _on_Project_Button_buttonPressed():
	project_button.visible = false
	global.game.ProjectComplete()

func Unpause():
	global.game.PauseTimer(false)
