module.exports = (robot) ->

  robot.respond /yo mama (.*)/i, (msg) ->
    cb = (m) -> msg.send m
    msg.http("http://api.yomomma.info/")
    .get() (err,res,body) ->
      joke_response = JSON.parse(body)
      cb msg.match[1] + ", " + joke_response.joke

  robot.respond /beer me/i, (msg) ->
    msg.send ":beer:"
    