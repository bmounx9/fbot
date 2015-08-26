# Description:
#   fbot is a fanasy football bot
#
# Commands:
#   fbot nfl teams - lists nfl teams
#   fbot nfl schedule <week #> - lists schedule for week
#
# Author:
#   bmounx9
#

Redis = require "redis"
Url = require "url"

module.exports = (robot) ->
  info = Url.parse process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379', true
  client = Redis.createClient(info.port, info.hostname)

  client.on "connect", ->
  robot.logger.info "Successfully connected to Redis"
  if info.auth
    client.auth info.auth.split(":")[1], (err) ->
      if err
        robot.logger.error "Failed to authenticate to Redis"
      else
        robot.logger.info "Successfully authenticated to Redis"

  robot.respond /yo mama (.*)/i, (msg) ->
    cb = (m) -> msg.send m
    msg.http("http://api.yomomma.info/")
    .get() (err, res, body) ->
      joke_response = JSON.parse(body)
      cb msg.match[1] + ", " + joke_response.joke

  robot.respond /beer me/i, (msg) ->
    msg.send ":beer:"

  robot.respond /draft order/i, (msg) ->
    msg.send "```1. Mark\n2. Tom\n3. Eric\n4. Yo\n5. Matt\n6. Brian\n7. Chris\n8. Kyle C.\n9. Chase\n10. Vince\n11. Kyle H.\n12. Akira```"

  robot.respond /nfl teams(.*)/i, (msg) ->
    cb = (m) -> msg.send "```" + m + "```"
    buildList = (data) ->
      for m in data['NFLTeams']
        if list
          list = list + '\n' + m.fullName
        else
          list = m.fullName
      return list
    client.get 'nflTeams', (err, reply) ->
      if err
        throw err
      else if reply
        cb buildList(JSON.parse(reply))
      else
        msg.http("http://www.fantasyfootballnerd.com/service/nfl-teams/json/shh3nn6ie9qt/")
        .get() (err, res, body) ->
          client.set 'nflTeams', body
          cb buildList(JSON.parse(body))

  robot.respond /nfl schedule( )?(week )?([0-9][0-9]?)?/i, (msg) ->
    cb = (m) -> msg.send "```" + m + "```"
    buildList = (data, match) ->
      match = if match then match else ''
      for m in data['Schedule']
        if (match && m.gameWeek == match) || match == ''
          if list
            list = list + '\n' + m.awayTeam + ' at ' + m.homeTeam + '\t[' + m.gameDate + ' ' + m.gameTimeET + ']'
          else
            list = m.awayTeam + ' at ' + m.homeTeam + '\t[' + m.gameDate + ' ' + m.gameTimeET + ']'
      return list
    client.get 'nflSchedule', (err, reply) ->
      if err
        throw err
      else if reply
        cb buildList(JSON.parse(reply), msg.match[3])
      else
        msg.http("http://www.fantasyfootballnerd.com/service/schedule/json/shh3nn6ie9qt/")
        .get() (err, res, body) ->
          client.set 'nflSchedule', body
          cb buildList(JSON.parse(body), msg.match[3])
