from cellworld import *
w = World.get_from_parameters_names("hexagonal", "canonical", "21_05")

print(w.configuration.get_values())

values = w.configuration.get_values()

c = World_configuration()

c.set_values(values)

print(c)
