class Logic extends EventEmitter
  constructor: (@map, types) ->
    @blockNum = 0
    for c in @map
      for v in c
        @blockNum += v
    cards = ((utils.randomInt types) + 1 for i in [0 ... @blockNum / 2])
    cards = cards.concat cards
    shuffleArray cards
    @map = for row in @map
      for v in row
        if v == 0 then 0 else cards.pop()
    @selected = []

    @subscribe = new EventEmitter()
    @on 'select', (data) =>
      console.log data
      @select data.x, data.y
    @subscribe.emit 'completed'

  select: (x, y) =>
    @selected.push [x, y]
    @subscribe.emit 'select', {x: x, y: y}
    console.log @selected
    if @selected.length == 2
      path = @check()
      if path?
        @map[@selected[0][0]][@selected[0][1]] = 0
        @map[@selected[1][0]][@selected[1][1]] = 0
        @blockNum -= 2
        @subscribe.emit 'gameEnd' if @blockNum <= 0
      @subscribe.emit 'selectClear', {path: path, selected: @selected}
      @selected = []

  check: () =>
    [[x1, y1], [x2, y2]] = @selected
    return undefined if x1 == x2 and y1 == y2
    return undefined if @map[x1][y1] != @map[x2][y2]

    markMap = for row in @map
      for v in row
        10000

    markMap[x1][y1] = 0
    queue = [[x1, y1, 0, []]]
    while queue.length > 0
      [x, y, deep, path] = queue.shift()
      continue if deep > 2
      for i in [-1, 0, 1]
        for j in [-1, 0, 1]
          continue if i == j or i == -j
          xx = i
          yy = j
          return path.concat [[x, y], [x2, y2]] if x + xx == x2 and y + yy == y2
          while (@map[x + xx]?[y + yy] == 0) and markMap[x + xx]?[y + yy] >= deep + 1
            markMap[x + xx][y + yy] = deep + 1
            queue.push [x + xx, y + yy, deep + 1, path.concat([[x, y]])]
            xx += i
            yy += j
            return path.concat [[x, y], [x2, y2]] if x + xx == x2 and y + yy == y2
    return undefined

shuffleArray = (array) ->
    for v, i in array
      t = utils.randomInt i
      [array[i], array[t]] = [array[t], array[i]]
    array

window.Logic = Logic
