def y1(x, a):
    if abs(x) > 4:
        return 2 * x
    return 4 + a


def y2(x, a):
    if x == 0:
        return 9
    return a / x


def y(x, a):
    return y1(x, a) + y2(x, a)


def main():
    a = 3
    for x in range(-15, 16):
        print(x, y(x, a))


if __name__ == "__main__":
    main()
