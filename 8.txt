color_list1 = []
color_list2 = []

n1 = int(input("Enter number of colors in first list: "))
for i in range(n1):
    color_list1.append(input("Enter color: "))

n2 = int(input("Enter number of colors in second list: "))
for i in range(n2):
    color_list2.append(input("Enter color: "))

print("Colors present in color_list1 but not in color_list2:")

for color in color_list1:
    if color not in color_list2:
        print(color)
