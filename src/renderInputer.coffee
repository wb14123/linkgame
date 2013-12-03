class RenderInputer extends EventEmitter
  constructor: (map, @height, @width, @effect, @stage) ->
    @subscribe = new EventEmitter()
    @row = map.length
    @col = map[0].length

    colors = []
    for i in [255, 100]
      for j in [255, 100]
        for k in [255, 100]
          colors.push "rgba(#{i}, #{j}, #{k}, 1)" unless i == 255 and j == 255 and k == 255
    @perWidth = @width / @row
    @perHeight =  @height / @col
    @blocks = for i in [0 ... @row]
      for j in [0 ... @col]
        if i == 0 or j == 0 or i == @row-1 or j == @col-1
          undefined
        else
          block = new createjs.Shape()
          block.x = i * @perWidth
          block.y = j * @perHeight
          block.i = i
          block.j = j
          block.type = map[i][j]
          block.down = false
          block.color = colors[map[i][j]]
          block.graphics.beginFill(colors[map[i][j]])
            .drawRect 0, 0, @perWidth * 0.9, @perHeight * 0.9
          @stage.addChild block
          createjs.Tween.get(block).wait(i + j).to({alpha: 1}, 700)
          do (i, j) =>
            block.on 'mousedown', () =>
              console.log [i, j]
              @subscribe.emit 'select', {x: i, y: j}
          block
    @stage.update()

    @on 'selectClear', (data) =>
      @select data.selected[0][0], data.selected[0][1]
      @select data.selected[1][0], data.selected[1][1]
      return undefined unless data.path?
      @drawPath data.path
      @removeBlock data.selected[0][0], data.selected[0][1]
      @removeBlock data.selected[1][0], data.selected[1][1]

    @on 'select', (data) =>
      @select data.x, data.y

  drawPath: (path) =>
    line = new createjs.Shape()
    color = @blocks[path[0][0]][path[0][1]].color
    linePen = line.graphics.setStrokeStyle(8, "round").beginStroke(color)
    linePen = linePen.moveTo path[0][0] * @perWidth + @perWidth / 2, path[0][1] * @perHeight + @perHeight / 2
    linePen = linePen.lineTo p[0] * @perWidth + @perWidth / 2, p[1] * @perHeight + @perHeight / 2 for p in path
    @stage.addChild line
    createjs.Tween.get(line).to({alpha: 0}, 500)
    setTimeout (() => @stage.removeChild line), 500

  select: (x, y) =>
    console.log [x, y]
    block = @blocks[x][y]
    if block.down
      block.scaleX= 1
      block.scaleY = 1
    else
      block.scaleX= 1.2
      block.scaleY= 1.2
    @blocks[x][y].down = !block.down
    @stage.update()

  removeBlock: (i, j) =>
    block = @blocks[i][j]
    block.removeAllEventListeners()

    if @effect == 0
      skewX = (utils.randomInt 100) - 50
      skewY = (utils.randomInt 100) - 50
      x = utils.randomInt @width
      y = utils.randomInt @height
      createjs.Tween.get(block).set({alpha: 0.1}).to({alpha: 0, x: x, y: y, skewX: skewX, skewY: skewY}, 5000)

    else
      x = block.x
      y = block.y
      scale = 4
      createjs.Tween.get(block, {override: true})
          .set({alpha: 0.1})
          .to({alpha: 0, x: x - scale * @perWidth, y: y - scale * @perHeight, scaleX: 2 * scale, scaleY: 2 * scale}, 5000)

    @stage.setChildIndex block, 0
    setTimeout (() => @stage.removeChild block), 5000

window.RenderInputer = RenderInputer
