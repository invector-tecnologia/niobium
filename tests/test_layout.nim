import std/unittest

import ../src/tatui

suite "layout: split truth-tables":
  test "length then fill":
    let cols = rect(0, 0, 10, 1).split(Horizontal, @[length(3), fill(1)])
    check cols == @[rect(0, 0, 3, 1), rect(3, 0, 7, 1)]

  test "percentages sum to parent":
    let cols = rect(0, 0, 10, 1).split(Horizontal, @[pct(50), pct(50)])
    check cols[0].width.int + cols[1].width.int == 10

  test "two fills split evenly":
    let cols = rect(0, 0, 10, 1).split(Horizontal, @[fill(1), fill(1)])
    check cols[0].width == 5
    check cols[1].width == 5

  test "vertical split with spacing":
    let rows = rect(0, 0, 4, 10).split(Vertical, @[length(2), length(2)], spacing = 1)
    check rows[0] == rect(0, 0, 4, 2)
    check rows[1] == rect(0, 3, 4, 2)

  test "min and fill":
    let cols = rect(0, 0, 20, 1).split(Horizontal, @[minSize(5), fill(1)])
    check cols[0].width == 5
    check cols[1].width == 15
