string=input("Enter a string: ")
if(len(string)>0):
    new_string=string[-1]+string[1:-1]+string[0]
else:
    new_string=string

print(new_string)