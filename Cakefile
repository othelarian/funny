
task 'probaMaterial', '', ->
  distrib = 0.55
  nbTour = 3
  val = 15.5
  t = (distrib * val * v for v in [1..nbTour])
  t = t.reduce ((a, b) => a + b), 0
  console.log(t / nbTour)






die = -> Math.floor(Math.random()*6) + 1
outDice = (prep, rolls, res) ->
  console.log "d: #{prep} => #{rolls} -> #{res}"


option '-a', '--action [NB]', ''
option '-d', '--defi [NB]', ''

task 'furoll', '', (opts) ->
  unless opts.hasOwnProperty 'action' then console.log 'no action roll nb'
  else
    rl = (nb) ->
      a = (die() for _ in [1..nb])
      ["[#{a.join(',')}]", a.filter((e) -> e > 4).length]
    prep = "#{opts.action}AD"
    actR = rl opts.action
    defR = ''
    res =
      if opts.hasOwnProperty 'defi'
        prep += ", #{opts.defi}DD"
        rr = rl opts.defi
        defR = ", #{rr[0]}"
        actR[1] - rr[1]
      else actR[1]
    outDice prep, "#{actR[0]}#{defR}", "#{res} succès"

option '-p', '--probable', ''
option '-i', '--improbable', ''

task 'recl', '', (opts) ->
  rl = (b = no) ->
    r = [die()]
    g =
      if b
        r.push die()
        if r[1] > r[0] then r[1] else r[0]
      else r[0]
    [g, "[#{r.join(',')}]"]
  nbA = rl opts.probable
  nbD = rl opts.improbable
  nbA.push(if opts.probable then 2 else 1)
  nbD.push(if opts.improbable then 2 else 1)
  prep = "#{nbA[2]}AD vs #{nbD[2]}DD"
  rolls = "#{nbA[1]} vs #{nbD[1]}"
  nua = (da, dd) ->
    switch
      when da > 3 and dd > 3 then ', et'
      when da < 4 and dd < 4 then ', mais'
      else ''
  res = switch
    when nbA[0] > nbD[0] then 'oui' + (nua nbA[0], nbD[0])
    when nbA[0] < nbD[0] then 'non' + (nua nbA[0], nbD[0])
    when nbA[0] == nbD[0]
      (if nbA[0] > 3 then 'oui' else 'non') + ', et Twist !'
  outDice prep, rolls, res

task 'roller', '', ->
  # Requires ########
  chokidar = require 'chokidar'
  coffee = require 'coffeescript'
  express = require 'express'
  fsp = require 'fs/promises'
  fs = require 'fs'
  sass = require 'sass'
  # Helpers #########
  createDir = ->
    try
      await fsp.mkdir './dist'
    catch err
      if err.code is 'EEXIST' then return else throw err
  getOutPth = (pth, lg) ->
    "./dist/#{pth.replace('./src/','').split('.')[0]}.#{lg}"
  checkCompile = (pth, lg) ->
    outPth = getOutPth pth, lg
    try
      dt = (fs.statSync outPth).mtimeMs
    catch err
      if err.code is 'ENOENT' then dt = 0
    st = (fs.statSync pth).mtimeMs
    [st > dt, outPth]
  compileStart = (lg) ->
    console.log "[#{new Date().toLocaleString()}] Compiling #{lg} ..."
  compileSuccess = (lg) ->
    console.log " => #{lg} compiled"
  compileCoffee = (pth) ->
    [ok, outPth] = checkCompile pth, 'js'
    if ok
      compileStart 'coffee'
      try
        code = await fsp.readFile pth, { encoding: 'utf-8' }
        out = coffee.compile code, {bare: yes}
        await fsp.writeFile outPth, out
      catch err
        console.log err
  compileSass = (pth) ->
    [ok, outPth] = checkCompile pth, 'css'
    if ok
      compileStart 'sass'
      try
        out = sass.compile pth, { style: 'compressed' }
        await fsp.writeFile outPth, out.css
      catch err
        console.log err
  # Instructions ####
  await createDir()
  compileSass './src/style.sass'
  compileCoffee './src/script.coffee'
  # launch chokidar
  watcher = chokidar.watch 'src'
  watcher.on 'change', (pth) =>
    console.Log "watcher, path => #{pth}"
    switch pth.split('.')[1]
      when 'coffee' then compileCoffee pth
      when 'sass'   then compileSass pth
  # launch the server
  port = 5001
  app = express()
  app.use express.static('./dist')
  app.set 'views', 'views'
  app.set 'view engine', 'pug'
  app.get '/', (_req, res) -> res.render 'roller'
  app.listen(port, => console.log "Listening on port #{port}")