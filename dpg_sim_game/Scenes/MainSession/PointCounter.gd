class_name PointCounter
extends Control

# Dependencies
onready var label = $Control/Label
onready var goodLabel = $Control/PointsMeter/GoodPoints
onready var badLabel = $Control/PointsMeter/BadPoints

var present = true

var good = 0
var bad = 0
var goodPos : Vector2
var badPos : Vector2

func Start():
	visible = present
	UpdateText()
	goodPos = goodLabel.rect_global_position + goodLabel.rect_size / 2
	badPos = badLabel.rect_global_position + badLabel.rect_size / 2

func LocalizeText(labelKey: String):
	label.text = trans.local(labelKey)

func AddPoint(isGood):
	if isGood:
		good += 1
	else:
		bad += 1
	UpdateText()

func CleanPoint():
	if bad > 0:
		bad -= 1
		UpdateText()

func UpdateText():
	goodLabel.text = str(good)
	badLabel.text = str(bad)

func Reset():
	good = 0
	bad = 0
	UpdateText()
