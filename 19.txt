class Rectangle:
    def __init__(self,length,breadth):
        self.length=length
        self.breadth=breadth

    def area(self):
        return self.length*self.breadth
    def perimeter(self):
        return 2*(self.length+self.breadth)

l1 = float(input("Enter length of rectangle 1: "))
b1 = float(input("Enter breadth of rectangle 1: "))
r1 = Rectangle(l1, b1)


l2 = float(input("Enter length of rectangle 2: "))
b2 = float(input("Enter breadth of rectangle 2: "))
r2 = Rectangle(l2, b2)


print("\nRectangle 1 Area:", r1.area())
print("Rectangle 1 Perimeter:", r1.perimeter())

print("\nRectangle 2 Area:", r2.area())
print("Rectangle 2 Perimeter:", r2.perimeter())


if r1.area() > r2.area():
    print("\nRectangle 1 has larger area")
elif r1.area() < r2.area():
    print("\nRectangle 2 has larger area")
else:
    print("\nBoth rectangles have equal area")