window.utils =

  randomInt: (num) ->
    return Math.floor(Math.random() * num)

  flow: (a, b, events) ->
    for e in events
      do (a, b, e) ->
        a.subscribe.on e, (data) ->
          b.emit e, data
