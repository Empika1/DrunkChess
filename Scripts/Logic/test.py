import math
for i in range(64):
    print(2**128 > math.factorial(64) / math.factorial(64-i), i)