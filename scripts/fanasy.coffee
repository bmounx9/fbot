module.exports = (robot) ->

  robot.respond /yo mama (.*)/i, (msg) ->
    cb = (m) -> msg.send m
    msg.http("http://api.yomomma.info/")
    .get() (err,res,body) ->
      joke_response = JSON.parse(body)
      cb msg.match[1] + ", " + joke_response.joke

  robot.respond /beer me/i, (msg) ->
    msg.send ":beer:"

  robot.respond /draft order/i, (msg) ->
    msg.send "```1. Mark\n2. Tom\n3. Eric\n4. Yo\n5. Matt\n6. Brian\n7. Chris\n8. Kyle C.\n9. Chase\n10. Vince\n11. Kyle H.\n12. Akira```"

  robot.respond /fanasy nfl teams(.*)/i, (msg) ->
    cb = (m) -> msg.send "```" + m + "```"
    getName = (m) ->
      if m.fullName != 'undefined'
        return m.fullName
      else
        return ''
    msg.http("http://www.fantasyfootballnerd.com/service/nfl-teams/json/shh3nn6ie9qt/")
    .get() (err,res,body) ->
      response = JSON.parse(body)
      for m in response['NFLTeams']
        if list
          list = list + '\n' + getName(m)
        else
          list = getName(m)
      cb list
