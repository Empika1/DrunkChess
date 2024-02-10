def isAClockwiseFromB(x1, y1, x2, y2):
    return x1*y2 < x2*y1

print(isAClockwiseFromB(1, 1, 0, 1))