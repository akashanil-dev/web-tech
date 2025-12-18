numbers = []

n = int(input("Enter number of elements: "))
for i in range(n):
    numbers.append(int(input("Enter number: ")))

odd_numbers = []

for num in numbers:
    if num % 2 != 0:
        odd_numbers.append(num)

print("Original list:", numbers)
print("List after removing even numbers:", odd_numbers)
