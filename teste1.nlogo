;; PARA VALORES INICIAIS
;;

globals [grass sheep-death vacas-death wolves-death lions-death]  ;; keep track of how much grass there is
;; Sheep and wolves are both breeds of turtle.
breed [sheep a-sheep]  ;; sheep is its own plural, so we use "a-sheep" as the singular.
breed [vacas vaca]
breed [wolves wolf]
breed [lions lion]
turtles-own [energy]       ;; both wolves and sheep have energy
patches-own [countdown]


to setup
  clear-all
  set vacas-death 0
  set sheep-death 0
  set wolves-death 0
  set lions-death 0

  ask patches [ set pcolor green ]
  ;; check GRASS? switch.
  ;; if it is true, then grass grows and the sheep eat it
  ;; if it false, then the sheep don't need to eat
  ask patches [
    set pcolor one-of [green brown]
      if-else pcolor = green
      [ set countdown grass-regrowth-time ]
      [ set countdown random grass-regrowth-time ] ;; initialize grass grow clocks randomly for brown patches
  ]
  make-mountain
  set-default-shape vacas "cow"
  create-vacas initial-number-vacas  ;; create the sheep, then initialize their variables
  [
    set color yellow
    set size 1.5  ;; easier to see
    set label-color pink - 2
    set energy random (2 * vacas-gain-from-food)
    posicionar         ;; posicionar todos os turtles fora da area preta, vide 'to posicionar'
  ]
  set-default-shape sheep "sheep"
  create-sheep initial-number-sheep  ;; create the sheep, then initialize their variables
  [
    set color white
    set size 1.5  ;; easier to see
    set label-color blue - 2
    set energy random (2 * sheep-gain-from-food)
    posicionar   ;; posicionar todos os turtles fora da area preta, vide 'to posicionar'
  ]
  set-default-shape wolves "wolf"
  create-wolves initial-number-wolves  ;; create the wolves, then initialize their variables
  [
    set color black
    set size 2  ;; easier to see
    ifelse wolf-gain-from-sheep > 0     ;; caso nao haja energia vindo dos sheep
        [set energy random (2 * wolf-gain-from-sheep)]
        [set energy random (2 * wolf-gain-from-cow)]        ;; os lobos serao inicializados com a energia vindo das vacas
    posicionar   ;; posicionar todos os turtles fora da area preta, vide 'to posicionar'
  ]
  set-default-shape lions "lion"
  create-lions initial-number-lions  ;; create the wolves, then initialize their variables
  [
    set color blue
    set size 2  ;; easier to see
    ifelse lion-gain-from-sheep > 0  ;; Caso nao haja ganho vindo dos sheep,
      [set energy random (2 * lion-gain-from-sheep)]     ;;
      [set energy random (2 * lion-gain-from-cow)]       ;; os leos serao inicializados usando o ganho vindo das vacas
    posicionar   ;; posicionar todos os turtles fora da area preta, vide 'to posicionar'
  ]
  display-labels
  set grass count patches with [pcolor = green]
  reset-ticks
end

to make-mountain
  ask patches [
    if pxcor > -100 and pxcor < 0 or pxcor > 0 and pxcor < 100 [
      if pycor < 4 and pycor > -4 [set pcolor black ]
    ]
  ]
end

to posicionar              ;; realoc any turtle put in black area
  setxy random-xcor random-ycor   ;; coloca o turtle em qualquer area
  ifelse pcolor = black          ;; se for colocado na area preta
    [posicionar]                  ;; posiciona novamente até nao colocar na area preta
       []
end

to go
  if not any? turtles [ stop ]
  ask vacas [
    vacas-move
    vacas-lose-energy ;;set energy energy - 1  ;; deduct energy for vaca
    vacas-eat-grass
    do-vacas-death
    reproduce-vacas
  ]
  ask sheep [
    sheep-move
    ;sheep-lose-energy;;set energy energy - 1  ;; deduct energy for sheep
    sheep-eat-grass
    do-sheep-death
    reproduce-sheep
  ]
  ask wolves [
    wolves-move
    ;wolves-lose-energy ;;set energy energy - 1  ;; wolves lose energy as they move
    catch-sheep
    catch-vacas
    do-wolves-death
    reproduce-wolves
  ]
  ask lions [
    lions-move
    lions-lose-energy ;;set energy energy - 1  ;; wolves lose energy as they move
    l-catch-vacas
    l-catch-sheep
    do-lions-death
    reproduce-lions
  ]
  ask patches [ grow-grass ]
  set grass count patches with [pcolor = green]
  tick
  display-labels
end

to lions-move

  ifelse any? other lions in-radius 20[             ;; se houver uma ovelha em um raio de 20 em relação ao leão
   face min-one-of other lions [ distance myself ]  ;; ele se rotaciona para a ovelha mais próxima
   rt 180
  ]
  [
    rt random 50                              ;; caso contrário, apenas se rotaciona aleatoriamente
     lt random 50
  ]
  forward 1



    if pcolor = black [         ;; se o turtle 'pisa' na area preta
      bk 1                      ;; da uma passo para traz
      move                      ;; e movimenta novamente, só funciona pq a direcao do movimento é aleatorio
      ]
end

to sheep-move

  ;;if (count other sheep in-radius 2 > 2)[
 ;;  ask other sheep in-radius 2 [die]
 ;; ]

  let x min-one-of lions in-radius 5 [distance myself] ;; x é o leão mais perto em um raio de 10
  ifelse (x != nobody) [                                ;; se x for alguém
     face min-one-of lions [ distance myself ]          ;; ele se rotaciona para o leão mais próximo
     rt 180                                             ;; se vira na direção oposta
     rt random 10                                       ;; e um pouco para algum dos lados
     lt random 10

 ]
  [

    let y min-one-of patches with [pcolor = green] in-radius 5  [ distance myself ] ;; se x for ninguém, y é o patch verde mais próximo

    if (y != nobody)[                                               ;; se y for alguém
      face min-one-of patches with [pcolor = green]  [ distance myself ];; ele se rotaciona para o patch verde mais próximo
      ]


  ]
  forward 1


  if pcolor = black [         ;; se o turtle 'pisa' na area preta
      bk 1                      ;; da uma passo para traz
      move                      ;; e movimenta novamente, só funciona pq a direcao do movimento é aleatorio
      ]

end

to vacas-move

  ;;if (count other vacas in-radius 2 > 2)[
   ;;ask other vacas in-radius 2 [die]
 ;; ]
  ifelse any? patches [                                                  ;; Se houver grama

      face min-one-of patches with [pcolor = green]  [ distance myself ] ;; a vaca se rotaciona para o patch verde mais próximo

  ]
  [
    rt random 50                ;; movimenta os turtles
    lt random 50
  ]


    forward 1

    if pcolor = black [         ;; se o turtle 'pisa' na area preta
      bk 1                      ;; da uma passo para traz
      move                      ;; e movimenta novamente, só funciona pq a direcao do movimento é aleatorio
      ]
end

to wolves-move


  let x min-one-of vacas in-radius 10 [distance myself];; x é a vaca mais perto em um raio de 10
  ifelse (x != nobody) [                               ;; se x for alguém
     face min-one-of vacas  [ distance myself ]        ;; ele se rotaciona para a vaca mais próxima
    forward 1
    set energy energy - 1
 ]
  [
    let y min-one-of sheep in-radius 10 [distance myself] ;; se x for ninguém, y é a ovelha mais próxima
    ifelse (y != nobody)[                                ;; se y for alguém
      face min-one-of sheep  [ distance myself ]         ;; ele se rotaciona para a ovelha mais próxima
      forward 1
      set energy energy - 1
    ]
    [
      if random 100 < 50                                 ;; se y for ninguém, o lobo tem uma chance de 3/4 de perder energia
      [set energy energy - 1]
    ]
  ]



    if pcolor = black [         ;; se o turtle 'pisa' na area preta
      bk 1                      ;; da uma passo para traz
      move                      ;; e movimenta novamente, só funciona pq a direcao do movimento é aleatorio
      ]
end

to move  ;; turtle procedure
  rt random 50                ;; movimenta os turtles
  lt random 50
    fd 1
    if pcolor = black [         ;; se o turtle 'pisa' na area preta
      bk 1                      ;; da uma passo para traz
      move                      ;; e movimenta novamente, só funciona pq a direcao do movimento é aleatorio
      ]
end

to vacas-lose-energy
  if random-float 100 < vacas-tmorte
     [set energy energy - 1]
end

to sheep-lose-energy
  if random-float 100 < sheep-tmorte
     [set energy energy - 1]
end

to wolves-lose-energy
  if random-float 100 < wolves-tmorte
     [set energy energy - 1]
end

to lions-lose-energy
  if random-float 100 < lions-tmorte
     [set energy energy - 1]
end

to vacas-eat-grass  ;; sheep procedure
  ;; sheep eat grass, turn the patch brown
  if pcolor = green [
      set pcolor brown
    set energy energy + vacas-gain-from-food  ;; sheep gain energy by eating
  ]
end

to sheep-eat-grass  ;; sheep procedure
  ;; sheep eat grass, turn the patch brown
  if pcolor = green [
      set pcolor brown
    set energy energy + sheep-gain-from-food  ;; sheep gain energy by eating
  ]
end

to reproduce-vacas  ;; sheep procedure
  if random-float 100 < vacas-reproduce [  ;; throw "dice" to see if you will reproduce
    set energy (energy / 2)                ;; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]   ;; hatch an offspring and move it forward 1 step
  ]
end

to reproduce-sheep  ;; sheep procedure
  if random-float 100 < sheep-reproduce [  ;; throw "dice" to see if you will reproduce
    set energy (energy / 2)                ;; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]   ;; hatch an offspring and move it forward 1 step
  ]
end

to reproduce-wolves  ;; wolf procedure
  if random-float 100 < wolf-reproduce [  ;; throw "dice" to see if you will reproduce
    set energy (energy / 2)               ;; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]  ;; hatch an offspring and move it forward 1 step
  ]
end
to reproduce-lions  ;; wolf procedure
  if random-float 100 < lion-reproduce [  ;; throw "dice" to see if you will reproduce
    set energy (energy / 2)               ;; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]  ;; hatch an offspring and move it forward 1 step
  ]
end

to catch-vacas  ;; wolf procedure
  let prey one-of vacas-here                    ;; grab a random sheep
  if prey != nobody                             ;; did we get one?  if so,
    [ ask prey [ die ]                          ;; kill it
      set energy energy + wolf-gain-from-cow ] ;; get energy from eating
end

to catch-sheep  ;; wolf procedure
  let prey one-of sheep-here                    ;; grab a random sheep
  if prey != nobody                             ;; did we get one?  if so,
    [ ask prey [ die ]                          ;; kill it
      set energy energy + wolf-gain-from-sheep ] ;; get energy from eating
end

to l-catch-vacas  ;; wolf procedure
  let prey one-of vacas-here                    ;; grab a random sheep
  if prey != nobody                             ;; did we get one?  if so,
    [ ask prey [ die ]                          ;; kill it
      set energy energy + lion-gain-from-cow ] ;; get energy from eating
end

to l-catch-sheep  ;; wolf procedure
  let prey one-of sheep-here                    ;; grab a random sheep
  if prey != nobody                             ;; did we get one?  if so,
    [ ask prey [ die ]                          ;; kill it
      set energy energy + lion-gain-from-sheep ] ;; get energy from eating
end

to do-vacas-death  ;; turtle procedure
  ;; when energy dips below zero, die
  if (energy < 0) or (random 100 < vacas-death)
    [ die ]
end

to do-sheep-death  ;; turtle procedure
  ;; when energy dips below zero, die
  if (energy < 0) or (random 100 < sheep-death)
    [ die ]
end

to do-wolves-death  ;; turtle procedure
  ;; when energy dips below zero, die
  if (energy < 0) or (random 100 < wolves-death)
    [ die ]
end

to do-lions-death  ;; turtle procedure
  ;; when energy dips below zero, die
  if (energy < 0) or (random 100 < lions-death)
    [ die ]
end

to grow-grass  ;; patch procedure
  ;; countdown on brown patches: if reach 0, grow some grass
  if pcolor = brown [
    ifelse countdown <= 0
      [ set pcolor green
        set countdown grass-regrowth-time ]
      [ set countdown countdown - 1 ]
  ]
end

to display-labels
  ask turtles [ set label "" ]
  if show-energy? [
    ask wolves [ set label round energy ]
    ask lions [ set label round energy ]
    ask sheep [ set label round energy ]
    ask vacas [ set label round energy ]
  ]
end


; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
714
24
1554
589
50
32
8.2245
1
14
1
1
1
0
0
0
1
-50
50
-32
32
1
1
1
ticks
60.0

SLIDER
6
122
180
155
initial-number-sheep
initial-number-sheep
0
250
74
1
1
NIL
HORIZONTAL

SLIDER
6
159
180
192
sheep-gain-from-food
sheep-gain-from-food
0.0
50.0
18
1.0
1
NIL
HORIZONTAL

SLIDER
6
194
180
227
sheep-reproduce
sheep-reproduce
1.0
20.0
1
1.0
1
%
HORIZONTAL

SLIDER
362
122
527
155
initial-number-wolves
initial-number-wolves
0
250
5
1
1
NIL
HORIZONTAL

SLIDER
362
158
527
191
wolf-gain-from-sheep
wolf-gain-from-sheep
0.0
20
10
0.25
1
NIL
HORIZONTAL

SLIDER
363
232
528
265
wolf-reproduce
wolf-reproduce
0.0
20.0
2
0.25
1
%
HORIZONTAL

SLIDER
5
68
217
101
grass-regrowth-time
grass-regrowth-time
0
100
48
1
1
NIL
HORIZONTAL

BUTTON
6
10
75
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
88
10
155
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
5
378
574
602
populations
time
pop.
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"sheep" 1.0 0 -7500403 true "" "plot count sheep"
"wolves" 1.0 0 -16777216 true "" "plot count wolves"
"grass / 4" 1.0 0 -10899396 true "" "plot grass / 4"
"vacas" 1.0 0 -1184463 true "" "plot count vacas"
"lions" 1.0 0 -13345367 true "" "plot count lions"

MONITOR
166
327
237
372
sheep
count sheep
3
1
11

MONITOR
243
327
325
372
wolves
count wolves
3
1
11

MONITOR
5
327
81
372
NIL
grass / 4
0
1
11

TEXTBOX
11
102
151
121
Sheep settings
11
0.0
0

TEXTBOX
367
102
480
120
Wolf settings
11
0.0
0

TEXTBOX
11
46
83
64
Grass settings
11
0.0
0

SWITCH
165
10
301
43
show-energy?
show-energy?
1
1
-1000

SLIDER
185
122
357
155
initial-number-vacas
initial-number-vacas
0
250
53
1
1
NIL
HORIZONTAL

SLIDER
185
158
357
191
vacas-gain-from-food
vacas-gain-from-food
0
100
20
1
1
NIL
HORIZONTAL

SLIDER
186
194
358
227
vacas-reproduce
vacas-reproduce
1.0
20.0
4
1.0
1
%
HORIZONTAL

MONITOR
85
327
159
372
vacas
count vacas
17
1
11

MONITOR
329
327
407
372
lions
count lions
17
1
11

SLIDER
537
122
709
155
initial-number-lions
initial-number-lions
0
300
25
1
1
NIL
HORIZONTAL

SLIDER
536
158
708
191
lion-gain-from-sheep
lion-gain-from-sheep
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
537
232
709
265
lion-reproduce
lion-reproduce
1.0
20.0
1
1.0
1
%
HORIZONTAL

SLIDER
225
68
608
101
initial-number-grass
initial-number-grass
0
2000
1484
1
1
NIL
HORIZONTAL

SLIDER
363
195
528
228
wolf-gain-from-cow
wolf-gain-from-cow
0
20
15.25
0.25
1
NIL
HORIZONTAL

SLIDER
536
195
708
228
lion-gain-from-cow
lion-gain-from-cow
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
6
231
178
264
sheep-tmorte
sheep-tmorte
0
100
100
1
1
%
HORIZONTAL

SLIDER
187
233
359
266
vacas-tmorte
vacas-tmorte
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
363
268
529
301
wolves-tmorte
wolves-tmorte
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
538
271
710
304
lions-tmorte
lions-tmorte
0
100
100
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model explores the stability of predator-prey ecosystems. Such a system is called unstable if it tends to result in extinction for one or more species involved.  In contrast, a system is stable if it tends to maintain itself over time, despite fluctuations in population sizes.

## HOW IT WORKS

There are two main variations to this model.

In the first variation, wolves and sheep wander randomly around the landscape, while the wolves look for sheep to prey on. Each step costs the wolves energy, and they must eat sheep in order to replenish their energy - when they run out of energy they die. To allow the population to continue, each wolf or sheep has a fixed probability of reproducing at each time step. This variation produces interesting population dynamics, but is ultimately unstable.

The second variation includes grass (green) in addition to wolves and sheep. The behavior of the wolves is identical to the first variation, however this time the sheep must eat grass in order to maintain their energy - when they run out of energy they die. Once grass is eaten it will only regrow after a fixed amount of time. This variation is more complex than the first, but it is generally stable.

The construction of this model is described in two papers by Wilensky & Reisman referenced below.

## HOW TO USE IT

1. Set the GRASS? switch to TRUE to include grass in the model, or to FALSE to only include wolves (red) and sheep (white).
2. Adjust the slider parameters (see below), or use the default settings.
3. Press the SETUP button.
4. Press the GO button to begin the simulation.
5. Look at the monitors to see the current population sizes
6. Look at the POPULATIONS plot to watch the populations fluctuate over time

Parameters:
INITIAL-NUMBER-SHEEP: The initial size of sheep population
INITIAL-NUMBER-WOLVES: The initial size of wolf population
SHEEP-GAIN-FROM-FOOD: The amount of energy sheep get for every grass patch eaten
WOLF-GAIN-FROM-FOOD: The amount of energy wolves get for every sheep eaten
SHEEP-REPRODUCE: The probability of a sheep reproducing at each time step
WOLF-REPRODUCE: The probability of a wolf reproducing at each time step
GRASS?: Whether or not to include grass in the model
GRASS-REGROWTH-TIME: How long it takes for grass to regrow once it is eaten
SHOW-ENERGY?: Whether or not to show the energy of each animal as a number

Notes:
- one unit of energy is deducted for every step a wolf takes
- when grass is included, one unit of energy is deducted for every step a sheep takes

## THINGS TO NOTICE

When grass is not included, watch as the sheep and wolf populations fluctuate. Notice that increases and decreases in the sizes of each population are related. In what way are they related? What eventually happens?

Once grass is added, notice the green line added to the population plot representing fluctuations in the amount of grass. How do the sizes of the three populations appear to relate now? What is the explanation for this?

Why do you suppose that some variations of the model might be stable while others are not?

## THINGS TO TRY

Try adjusting the parameters under various settings. How sensitive is the stability of the model to the particular parameters?

Can you find any parameters that generate a stable ecosystem that includes only wolves and sheep?

Try setting GRASS? to TRUE, but setting INITIAL-NUMBER-WOLVES to 0. This gives a stable ecosystem with only sheep and grass. Why might this be stable while the variation with only sheep and wolves is not?

Notice that under stable settings, the populations tend to fluctuate at a predictable pace. Can you find any parameters that will speed this up or slow it down?

Try changing the reproduction rules -- for example, what would happen if reproduction depended on energy rather than being determined by a fixed probability?

## EXTENDING THE MODEL

There are a number ways to alter the model so that it will be stable with only wolves and sheep (no grass). Some will require new elements to be coded in or existing behaviors to be changed. Can you develop such a version?

Can you modify the model so the sheep will flock?

Can you modify the model so that wolf actively chase sheep?

## NETLOGO FEATURES

Note the use of breeds to model two different kinds of "turtles": wolves and sheep. Note the use of patches to model grass.

Note use of the ONE-OF agentset reporter to select a random sheep to be eaten by a wolf.

## RELATED MODELS

Look at Rabbits Grass Weeds for another model of interacting populations with different rules.

## CREDITS AND REFERENCES

Wilensky, U. & Reisman, K. (1999). Connected Science: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. International Journal of Complex Systems, M. 234, pp. 1 - 12. (This model is a slightly extended version of the model described in the paper.)

Wilensky, U. & Reisman, K. (2006). Thinking like a Wolf, a Sheep or a Firefly: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. Cognition & Instruction, 24(2), pp. 171-209. http://ccl.northwestern.edu/papers/wolfsheep.pdf

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Wolf Sheep Predation model.  http://ccl.northwestern.edu/netlogo/models/WolfSheepPredation.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2000.

<!-- 1997 2000 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

lion
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 27 192 25 204 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 206 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 102 219 111 216 118 213 140 215 160 213 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 216 151 250 160 266 159 281 158 280 142 298 147 299 134 297 127 278 124 273 109
Polygon -7500403 true true -1 195 14 180 11 167 20 154 26 140 68 117 124 127 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113
Polygon -7500403 false true 213 87 243 102 213 117 198 87 213 87 213 162 243 177 258 162 243 147 243 117 228 87 213 87 183 87 168 102 168 117 183 132 198 132
Rectangle -7500403 true true 189 105 214 124
Rectangle -7500403 true true 188 97 225 119
Polygon -7500403 true true 252 102 229 95 235 81 179 89 157 108 151 119 148 129 149 149 181 198 209 210 237 182 257 164 262 148 244 110 224 82 234 82 245 82

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
set grass? true
setup
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
