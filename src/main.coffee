
init = ->
  canvas = document.getElementById 'myCanvas'
  width = canvas.width = window.innerWidth
  height = canvas.height = window.innerHeight
  stage = new createjs.Stage 'myCanvas'
  createjs.Touch.enable stage
  createjs.Ticker.on 'tick', () ->
    stage.update()

  row = 4
  col = 4
  map = for i in [0..row + 1]
    for j in [0..col + 1]
      if i == 0 or i == row + 1 or j == 0 or j == col + 1 then 0 else 1

  logic = new Logic map, 5
  render = new RenderInputer logic.map, height, width, 0, stage

  utils.flow logic, render, ["selectClear", "select"]
  utils.flow render, logic, ['select']

