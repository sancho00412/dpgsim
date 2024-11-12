class_name GameTooltip
extends CanvasLayer

# Dependencies
onready var title = $CenterContainer/Control/TooltipWindow/Title
onready var body = $CenterContainer/Control/TooltipWindow/Body
onready var mm_button = $CenterContainer/Control/TooltipWindow/MM_Button

var callback
var closeIsProceed = false

func SetTooltip(titleText, bodyText, _callback):
	title.text = titleText
	body.text = bodyText
	mm_button.Start()
	callback = _callback
	visible = true

func _on_MM_Button_buttonPressed():
	visible = false
	if closeIsProceed:
		closeIsProceed = false
	if callback != null:
		callback.call_func()

func _on_CloseButton_pressed():
	global.game.soundManager.PlaySFX("Tick")
	if closeIsProceed:
		closeIsProceed = false
		_on_MM_Button_buttonPressed()
		return
	visible = false
