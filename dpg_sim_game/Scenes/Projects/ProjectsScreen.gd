extends Node

export var numProjects = 4

# Dependencies
onready var projectOptions = [
	$CenterContainer/Options/ProjectOption1,
	$CenterContainer/Options/ProjectOption2, 
	$CenterContainer/Options/ProjectOption3, 
	$CenterContainer/Options/ProjectOption4
]

func Start():
	var randInds = []
	var projectInds = global.curPhase()
	for i in range(projectInds.size()):
		randInds.append(i)
	
	numProjects = min(4, projectInds.size())
	for i in range(4):
		projectOptions[i].visible = i < numProjects
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(numProjects):
		var ind = rng.randi_range(0, randInds.size()-1)
		var project = global.projects[projectInds[randInds[ind]]]
		randInds.remove(ind)
		projectOptions[i].InitProjectButton(project)
