
window.init = ->
  canvas = document.getElementById 'myCanvas'
  width = canvas.width = window.innerWidth
  height = canvas.height = window.innerHeight
  stage = new createjs.Stage 'myCanvas'
  createjs.Touch.enable stage
  createjs.Ticker.on 'tick', () ->
    stage.update()
  newGame stage, 4, 4, width, height


newGame = (stage, row, col, width, height) ->
  map = for i in [0..row + 1]
    for j in [0..col + 1]
      if i == 0 or i == row + 1 or j == 0 or j == col + 1 then 0 else 1
  logic = new Logic map, 5
  render = new RenderInputer logic.map, width, height,  utils.randomInt(2), stage
  logic.subscribe.on 'gameEnd', () ->
    newGame stage, row + 2, col + 2, width, height
  utils.flow logic, render, ["selectClear", "select"]
  utils.flow render, logic, ['select']
