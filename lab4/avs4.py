def y1(x, a):
    if x < 1:
        return 8 + abs(x)
    return abs(a) * 2


def y2(x, a):
    if x == a:
        return 3
    return a + 1


def y(x, a):
    return y1(x, a) % y2(x, a)


def main():
    a = 3
    for x in range(0, 15):
        print("x = {0:d}    y1 = {1:d}    y2 = {2:d}   y = {3:d} ({3:X}x)".format(x, y1(x, a), y2(x, a), y(x, a)))


if __name__ == "__main__":
    main()
