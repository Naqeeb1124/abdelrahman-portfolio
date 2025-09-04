import cadquery as cq

# Base plate
base = cq.Workplane("XY").box(100, 100, 3, centered=(False, False, False)).translate((0, 0, -3))

# Vertical web
web = cq.Workplane("XY").box(100, 3, 50, centered=(False, False, False)).translate((0, -3, 0))

# Union
l_bracket = base.union(web)

# Fillet inside corner
all_edges = l_bracket.edges("|X").all()
filtered_edges = [e for e in all_edges if e.val().Center().y == 0 and e.val().Center().z == 0]
l_bracket = l_bracket.edges(filtered_edges).fillet(2.9)

# Frame mounting holes on base
l_bracket = l_bracket.faces(">Z").workplane().pushPoints([(10, 10), (90, 10), (10, 90), (90, 90)]).hole(3.4, depth=3)

# Avionics holes on web
l_bracket = l_bracket.faces("<Y").workplane().pushPoints([(20, 5), (80, 5), (20, 45), (80, 45)]).hole(3.4, depth=3)

# Slot on web
l_bracket = l_bracket.faces("<Y").workplane().moveTo(50, 12).slot2D(20, 8, 0).cutThruAll()

# Lightening holes on web
l_bracket = l_bracket.faces("<Y").workplane().pushPoints([(25, 30), (50, 30), (75, 30)]).hole(25, depth=3)

# Gusset A
gusset_a = cq.Workplane("XZ").polyline([(5, 0), (35, 0), (5, 50)]).close().extrude(3, direction=(0, 1, 0))
all_edges = gusset_a.edges("|X").all()
filtered_edges = [e for e in all_edges if e.val().Center().z == 0 and e.val().Center().y == 0]
gusset_a = gusset_a.edges(filtered_edges).fillet(3)
all_edges = gusset_a.edges("|Z").all()
filtered_edges = [e for e in all_edges if e.val().Center().x == 5 and e.val().Center().y == 0]
gusset_a = gusset_a.edges(filtered_edges).fillet(3)

# Gusset B
gusset_b = cq.Workplane("XZ").polyline([(65, 0), (95, 0), (65, 50)]).close().extrude(3, direction=(0, 1, 0))
all_edges = gusset_b.edges("|X").all()
filtered_edges = [e for e in all_edges if e.val().Center().z == 0 and e.val().Center().y == 0]
gusset_b = gusset_b.edges(filtered_edges).fillet(3)
all_edges = gusset_b.edges("|Z").all()
filtered_edges = [e for e in all_edges if e.val().Center().x == 65 and e.val().Center().y == 0]
gusset_b = gusset_b.edges(filtered_edges).fillet(3)

# Union gussets
l_bracket = l_bracket.union(gusset_a).union(gusset_b)

# Chamfer external edges
l_bracket = l_bracket.edges().chamfer(0.5)

# The show_object function is used by cq-editor to display CadQuery objects.
show_object(l_bracket)