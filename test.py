list1 = ['ruslan']
list2 = ['ruslan', '99']
mylist = list(set(list1[0]).difference(set(list(list2[0]))))
if mylist:print(True)
else:print(False)
