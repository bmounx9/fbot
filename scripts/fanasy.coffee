Redis = require "redis"
Url = require "url"

module.exports = (robot) ->

  info   = Url.parse process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379', true
  client = Redis.createClient(info.port, info.hostname)

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

  robot.respond /nfl teams(.*)/i, (msg) ->
    cb = (m) -> msg.send "```" + m + "```"
    data = {}
    client.get "nflTeams", (err, reply) ->
      if err
        throw err
      else if reply
        data = JSON.parse(reply)
      else
        msg.http("http://www.fantasyfootballnerd.com/service/nfl-teams/json/shh3nn6ie9qt/")
          .get() (err,res,body) ->
            data = JSON.parse(body)
            client.set 'nflTeams', body
    for m in response['NFLTeams']
      if list
        list = list + '\n' + m.fullName
      else
        list = getName(m)
    cb list

  robot.respond /nfl schedule( )?(week )?([0-9][0-9]?)?/i, (msg) ->
    cb = (m) -> msg.send "```" + m + "```"
    msg.http("http://www.fantasyfootballnerd.com/service/schedule/json/shh3nn6ie9qt/")
    .get() (err,res,body) ->
      response = JSON.parse(body)
      match = if msg.match[3] then msg.match[3] else ''
      for m in response['Schedule']
        if (match && m.gameWeek == match) || match == ''
          if list
            list = list + '\n' + m.awayTeam + ' at ' + m.homeTeam + '\t[' + m.gameDate + ' ' + m.gameTimeET + ']'
          else
            list = m.awayTeam + ' at ' + m.homeTeam + '\t[' + m.gameDate + ' ' + m.gameTimeET + ']'
      cb list
