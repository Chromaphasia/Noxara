extends Node

func roundAway(x: float):
	if x == 0:
		return 0
	if x < 0:
		return floor(x)
	return ceil(x)
