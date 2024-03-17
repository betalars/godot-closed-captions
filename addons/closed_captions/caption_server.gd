extends Node
class_name CaptionServer

var sources: Array[Array] = [[],[]]
var captions: Array[ServerCaption]


func update_source(source: CaptionedAudioStreamPlayer):
	var listener = source.get_viewport()
	if !sources[0].has(listener):
		sources[0].append(listener)
	sources[1][sources[0].find(listener)].append(source)

func push_caption(source: Node, caption: Caption):
	pass
