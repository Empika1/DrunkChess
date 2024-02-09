def nextSpiralPos(x, y):
    if (y <= x - 1) and (y > -x):
        return (x, y - 1)
    if (y <= -x) and (y < x):
        return (x - 1, y)
    if (y >= x) and (y < -x):
        return (x, y + 1)
    if (y >= -x) and (y > x - 1):
        return (x + 1, y)

pointsHit = set()
pos = (0, 0)
for i in range(20):
    pointsHit.add(pos)
    pos = nextSpiralPos(*pos)