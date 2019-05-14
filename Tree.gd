extends Tree

func _ready():
	var root = create_item()
	set_hide_root(true)
	var child1 = create_item(root)
	child1.set_text(0, "Suspense")
	var subchild1 = create_item(child1)
	subchild1.set_text(0, "horror.mp3")

	var child2 = create_item(root)
	child2.set_text(0, "Relaxing")
	var subchild2 = create_item(child2)
	subchild2.set_text(0, "doin.mp3")