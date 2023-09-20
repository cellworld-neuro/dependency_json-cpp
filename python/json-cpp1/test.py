from src import *
json_string = '{"a":10, "b":{"c":1, "d":2}}'
a = JsonObject.load(json_string)
print(a, a.b)
print(a["b"])
a["a"] = 100
print(a)

for e in a:
    print(e)


class Location(JsonObject):
    def __init__(self, x=0, y=0):
        JsonObject.__init__(self)
        self.x = float(x)
        self.y = float(y)
        self.z = JsonObject(x=x*3, y=y*4)
        self.s = "hello!"

Location_list = JsonList.create_type(Location, "Location_list")

ll = Location_list()

for i in range(10):
    ll.append(Location(i, i*2))

print(ll)


for i in ll:
    print(i["z.x"])
    i["z.x"] += 10
    print(i.get_columns())
    print(i.get_numeric_columns())

a = ll.to_numpy_array()
print(a)

nll = Location_list()
nll.from_numpy_array(a)

print (nll)

df = nll.to_dataframe()
print(df)

nlll = Location_list()
nlll.from_dataframe(df)
print(nlll)


