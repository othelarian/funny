# HELPERS ########################################

addOnTop = (parent, node) ->
  if parent.hasChildNodes()
    parent.insertBefore node, parent.firstChild
  else
    parent.appendChild node

clearChildren = (node) ->
  while node.lastElementChild
    node.removeChild node.lastElementChild

createElt = (tag, attrs = {}, content = '') ->
  elt = document.createElement tag
  elt.setAttribute(key, value) for key, value of attrs
  if content isnt '' then elt.textContent = content
  elt

getElt = (selector, all = no) ->
  if all then document.querySelectorAll selector
  else document.querySelector selector

# RES TOOLING ####################################

resClick = -> await navigator.clipboard.writeText(res.r)

die = (nb = 6) -> Math.floor(Math.random() * nb) + 1

res = {}

resetRes = (type = 'none') ->
  res = {spec: {type: type}, prep: '', rolls: '', res: '', r:''}

outRes = (rev = no) ->
  res.r = "d: #{res.prep} => #{res.rolls} -> #{res.res}"
  resClick()
  histoSave(res, rev)
  getElt('.result').textContent = res.r

numberBlur = (trgt, lmt) ->
  inp = getElt "##{trgt}"
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

statutRes = (rev = no) ->
  res.prep = "Statut #{res.spec.n}"
  res.rolls = "[#{res.spec.rolls.join(',')}]"
  res.spec.succ = res.spec.rolls.filter((e) -> e > 4).length
  res.res = "#{res.spec.succ} succès"
  outRes(rev)

statutRoll = ->
  resetRes 'statut'
  res.spec.n = parseInt document.getElementById('statut').value
  res.spec.rolls = (die() for _ in [1..res.spec.n])
  statutRes()

statutAdd = -> if res.spec.type is 'statut'
  res.spec.n += 1
  res.spec.rolls.push die()
  statutRes(yes)

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
    outRes(yes)

choixReset = (f = no) ->
  document.getElementById('choix-lab').value = '--'
  res.res = '--'
  unless f then outRes(yes)

# HISTORIQUE #####################################

histo = []

histoClean = ->
  localStorage.removeItem 'funny-histo'
  histo = []
  clearChildren getElt('#histo')

histoRem = (evt) ->
  #
  console.log evt
  #
  localStorage.setItem 'funny-histo', JSON.parse(histo)
  #

histoSave = (data, rev = no, nosave = no) ->
  if nosave or histo.length is 0
    getElt('#histo-ctrl').classList.remove 'hide'
  if rev
    #
    console.log 'modify last entry'
    #
  else
    #
    #idx = 
    #
    div = createElt 'div', {}, data.r
    #btn = createElt 'button', {'onclick': 'histoRem()'}, 'X'
    #
    #div.appendChild btn
    addOnTop getElt('#histo'), div
  unless nosave
    histo.push data
    localStorage.setItem 'funny-histo', JSON.stringify(histo)

# INIT ###########################################

init = ->
  # get back the histo, if exists
  if localStorage.hasOwnProperty 'funny-histo'
    histo = JSON.parse localStorage.getItem('funny-histo')
    histoSave(data, no, yes) for data from histo
  # finish the init by a reset
  resetRes()
