
init = ->
  canvas = document.getElementById 'myCanvas'
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight

  stage = new createjs.Stage 'myCanvas'
  createjs.Touch.enable stage
  newGame = (event) ->
    game = new Game canvas.width, canvas.height, stage, 6, 6, Math.floor(Math.random() * 2)
    game.subscribe.on 'gameEnd', newGame
  newGame()

  createjs.Ticker.on 'tick', () ->
    stage.update()

class Game
  constructor: (@width, @height, @stage, @row, @col, @effect) ->
    @perWidth = @width / (@row + 2)
    @perHeight =  @height / (@col + 2)
    pColors = []
    for i in [255, 100]
      for j in [255, 100]
        for k in [255, 100]
          pColors.push [i, j, k]
    selectedC = pColors[Math.floor(Math.random() * pColors.length)]
    console.log c
    @types = 5
    @colors = []
    for i in [0...@types]
      c = ((j + Math.random() * 200) for j in selectedC)
      max = Math.max c[0], c[1], c[2]
      c = (Math.floor(j / max * 255) for j in c)
      console.log c
      @colors.push "rgba(#{c[0]}, #{c[1]}, #{c[2]}, 1)"

    background = new createjs.Shape()
    background.graphics.beginFill("rgba(#{selectedC[0] * 1.2}, #{selectedC[1] * 1.2}, #{selectedC[2] * 1.2}, 1)").drawRect(0, 0, @width, @height)
    # stage.addChild background

    @selected = []
    @subscribe = new EventEmitter()

    mapArray = (i % @types for i in [0...@row * @col / 2])
    mapArray = mapArray.concat mapArray
    for i in [0...@row * @col]
      t = Math.floor(Math.random() * i)
      [mapArray[i], mapArray[t]] = [mapArray[t], mapArray[i]]

    @map =
      for i in [0..@row + 1]
        for j in [0..@col + 1]
          if i == 0 or j == 0 or i > @row or j > @col
            undefined
          else
            new Block i, j, @perWidth, @perHeight, mapArray.pop(), @stage, this, @colors, @effect

    @timer = new createjs.Shape()
    console.log selectedC
    @timer.graphics.beginFill("rgba(#{selectedC[0]}, #{selectedC[1]}, #{selectedC[2]}, 1)").drawRect(0, 0, @width, 10)
    @stage.addChild @timer
    @allTime = @remindTime = 10000
    @blockNum = @row * @col
    createjs.Tween.get(@timer).wait(3000).to({x: -@width}, @remindTime)

  select: (i, j) =>
    @selected.push [i, j]
    if @selected.length == 2
      path = @check()
      @update(path)

  check: () =>
    [[x1, y1], [x2, y2]] = @selected
    return false if x1 == x2 and y1 == y2
    return false if @map[x1][y1].type != @map[x2][y2].type

    markMap = for i in [0..@row + 1]
      for j in [0..@col + 1]
        10000

    markMap[x1][y1] = 0
    queue = [[x1, y1, 0, []]]
    while queue.length > 0
      [x, y, deep, path] = queue.shift()
      continue if deep > 2
      for i in [-1..1]
        for j in [-1..1]
          continue if i == j or i == -j
          xx = i
          yy = j
          return path.concat [[x, y], [x2, y2]] if x + xx == x2 and y + yy == y2
          while (not @map[x + xx]?[y + yy]?) and markMap[x + xx]?[y + yy] >= deep + 1
            markMap[x + xx][y + yy] = deep + 1
            queue.push [x + xx, y + yy, deep + 1, path.concat([[x, y]])]
            xx += i
            yy += j
            return path.concat [[x, y], [x2, y2]] if x + xx == x2 and y + yy == y2
    return undefined

  update: (path) =>
    [[x1, y1], [x2, y2]] = @selected
    @map[x1][y1].select()
    @map[x2][y2].select()
    @selected = []
    return unless path
    @drawPath path
    @map[x1][y1].remove()
    @map[x2][y2].remove()
    delete @map[x1][y1]
    delete @map[x2][y2]
    @addTime(1000)
    @blockNum -= 2
    if @blockNum <= 0
      @subscribe.emit 'gameEnd', 'win'

  addTime: (time) =>
    console.log @timer.x
    remindTime = (@width + @timer.x) / @width * @allTime
    remindTime += time
    remindTime = @allTime if remindTime > @allTime
    x = remindTime / @allTime * @width - @width
    createjs.Tween.get(@timer, {override: true}).to({x: x}, 200).to({x: -@width}, @remindTime - 200)

  drawPath: (path) ->
    line = new createjs.Shape()
    color = @colors[@map[path[0][0]][path[0][1]].type]
    linePen = line.graphics.setStrokeStyle(8, "round").beginStroke(color)
    linePen = linePen.moveTo path[0][0] * @perWidth + @perWidth / 2, path[0][1] * @perHeight + @perHeight / 2
    linePen = linePen.lineTo p[0] * @perWidth + @perWidth / 2, p[1] * @perHeight + @perHeight / 2 for p in path
    @stage.addChild line
    createjs.Tween.get(line).to({alpha: 0}, 500)
    setTimeout (() => @stage.removeChild line), 500
    @stage.update()

class Block
  constructor: (@i, @j, @width, @height, @type, @stage, @game, @colors, @effect) ->
    @block = new createjs.Shape()
    x  = @width * @i
    y = @height * @j
    @block.x = x
    @block.y = y
    console.log @colors[@type]
    @block.graphics.beginFill(@colors[@type]).drawRect 0, 0,
      @width - @width / 10,
      @height - @height / 10
    @stage.addChild @block

    @block.alpha = 0
    @block.on 'mousedown', @select
    @down = false
    setTimeout @show, (@i + @j) * 150

  show: () =>
    createjs.Tween.get(@block).to({alpha: 1}, 700)

  select: () =>
    if @down
      @block.scaleX= 1
      @block.scaleY = 1
    else
      x = @width * @i
      @block.scaleX= 1.2
      @block.scaleY= 1.2
    @down = !@down
    @game.select(@i, @j)

  remove: () =>
    @block.removeAllEventListeners()
    console.log @effect

    if @effect == 0
      skewX = (Math.random() - 0.5)  * 100
      skewY = (Math.random() - 0.5) * 100
      x = (Math.random() - 0.5) * 20 * @width
      y = (Math.random() - 0.5) * 20 * @height
      createjs.Tween.get(@block).set({alpha: 0.1}).to({alpha: 0, x: x, y: y, skewX: skewX, skewY: skewY}, 5000)
    else
      x = @block.x
      y = @block.y
      scale = 4
      console.log [x, y]
      createjs.Tween.get(@block, {override: true})
          .set({alpha: 0.1})
          .to({alpha: 0, x: x - scale * @width, y: y - scale * @height, scaleX: 2 * scale, scaleY: 2 * scale}, 5000)
    @stage.setChildIndex @block, 1
    setTimeout (() => @stage.removeChild @block), 5000

window.init = init
