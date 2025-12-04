# HELPERS ########################################

resClick = -> await navigator.clipboard.writeText(res.r)

die = (nb = 6) -> Math.floor(Math.random() * nb) + 1

res = {}

resetRes = (type = 'none') ->
  res = {spec: {type: type}, prep: '', rolls: '', res: '', r:''}

outRes = ->
  res.r = "d: #{res.prep} => #{res.rolls} -> #{res.res}"
  resClick()
  document.querySelector('.result').textContent = res.r

numberBlur = (trgt, lmt) ->
  inp = document.getElementById trgt
  v = parseInt inp.value
  unless not isNaN(v) and v >= lmt then inp.value = lmt

numberMod = (trgt, dir, lmt) ->
  inp = document.getElementById trgt
  v = parseInt(inp.value) + dir
  unless v < lmt then inp.value = v

# ROLLS - FUROLL ################################

furollRoll = ->
  resetRes 'furoll'
  ad = parseInt document.getElementById('furoll-ad').value
  dd = parseInt document.getElementById('furoll-dd').value
  rl = (nb) ->
    a = (die() for _ in [1..nb])
    ["[#{a.join(',')}]", a.filter((e) -> e > 4).length]
  res.prep = "#{ad}AD"
  [res.rolls, sucp] = rl ad
  suc =
    if dd > 0
      res.prep += ", #{dd}DD"
      [rls, sucn] = rl dd
      res.rolls += ", #{rls}"
      sucp - sucn
    else sucp
  res.res = "#{suc} succès"
  outRes()

# ROLLS - ORACLE ################################

oracle = (prop = 'normal') ->
  # prop = 'improbable' | 'normal' | 'probable'
  resetRes 'oracle'
  rl = (b = no) ->
    r = [die()]
    g =
      if b
        r.push die()
        if r[1] > r[0] then r[1] else r[0]
      else r[0]
    [g, "[#{r.join(',')}]"]
  nbA = rl(prop is 'probable')
  nbD = rl(prop is 'improbable')
  nbA.push(if prop is 'probable' then 2 else 1)
  nbD.push(if prop is 'improbable' then 2 else 1)
  res.prep = "#{nbA[2]}AD vs #{nbD[2]}DD"
  res.rolls = "#{nbA[1]} vs #{nbD[1]}"
  nua = (da, dd) ->
    switch
      when da > 3 and dd > 3 then ', et'
      when da < 4 and dd < 4 then ', mais'
      else ''
  res.res = switch
    when nbA[0] > nbD[0] then 'oui' + (nua nbA[0], nbD[0])
    when nbA[0] < nbD[0] then 'non' + (nua nbA[0], nbD[0])
    when nbA[0] == nbD[0]
      (if nbA[0] > 3 then 'oui' else 'non') + ', et Twist !'
  outRes()

# ROLLS - STATUT #################################

statutRes = ->
  res.prep = "Statut #{res.spec.n}"
  res.rolls = "[#{res.spec.rolls.join(',')}]"
  res.spec.succ = res.spec.rolls.filter((e) -> e > 4).length
  res.res = "#{res.spec.succ} succès"
  outRes()

statutRoll = ->
  resetRes 'statut'
  res.spec.n = parseInt document.getElementById('statut').value
  res.spec.rolls = (die() for _ in [1..res.spec.n])
  statutRes()

statutAdd = -> if res.spec.type is 'statut'
  res.spec.n += 1
  res.spec.rolls.push die()
  statutRes()

# ROLLS - CHOIX ##################################

choixRoll = ->
  resetRes 'choix'
  nb = parseInt document.getElementById('choix').value
  res.prep = "Choix 1d#{nb}"
  res.rolls = "[#{die(nb)}]"
  choixReset yes
  outRes()

choixMod = ->
  if res.spec.type is 'choix'
    res.res = document.getElementById('choix-lab').value
    outRes()

choixReset = (f = no) ->
  document.getElementById('choix-lab').value = '--'
  res.res = '--'
  unless f then outRes()

# INIT ###########################################

init = ->
  resetRes()
