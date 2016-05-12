words = sc.textFile("/home/hduser/data/imagine.txt")
result = words.filter(lambda w: w.startswith("I")).take(5)
print result
