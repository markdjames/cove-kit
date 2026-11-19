extends Pirate
## A game's own lines for Emmy, as a game sets on its instance of pirate.tscn.

const GREETING := "Ahoy!"


func greet() -> void:
	speak(Pose.WAITING, GREETING)
