breed [pessoas pessoa]

pessoas-own[
  virus?
  age
  incubation-duration
  virus-duration
  immune-duration
  vac-duration
  mask?
]

globals[
  dead
  recovered
  born
  infected
  vaccinated
]

to setup
  clear-all
  reset-ticks
  ask patches [ set pcolor white ]
  create-pessoas Starting-Population [
    set vac-duration 90
    set virus? false
    set mask? false
    set age random 80 * 52 * 7
    set color green
    set shape "circle"
    setxy random-xcor random-ycor
  ]
  ask n-of Starting-infection pessoas [ get-sick ]
end

to go
  ;reset-timer
  if ticks = maxit [stop]
  reset-mask
  vacination
  ask pessoas[
    if vac? [update-vac]
    move
    update-sickness
    reproduce
    set age age - 1
    if age = 0 [ die ]
  ]
   ;while [timer < 1 / tick-rate ] []
  tick
end

to vacination
  ifelse (count pessoas * (Vax/day / 100)) > count pessoas with [not (virus? and not incubation?) and not vac?]
  [
    ask pessoas with [not (virus? and not incubation?) and not vac?]
    [
      set vac-duration (- (Incubation-time - random (Incubation-time / 3) + random (Incubation-time / 3)))
      set color Magenta
      set vaccinated vaccinated + 1
    ]
  ]
  [
    ask n-of (count pessoas * (Vax/day / 100)) pessoas with [not ( virus? and not incubation?) and not vac?]
    [
      set vac-duration (- (Incubation-time - random (Incubation-time / 3) + random (Incubation-time / 3)))
      set color Magenta
      set vaccinated vaccinated + 1
    ]
  ]

end

to reset-mask
  ask pessoas [set mask? false]
  ask n-of (count pessoas * (mask% / 100)) pessoas [set mask? true]
end

to update-sickness ;pessoas procedure
  update-immune
  ifelse virus? and incubation? [ progress ]
  [
    ifelse virus?
    [
      progress spread-sick
    ] [
      if not immune? [ spread-healthy ]
    ]
  ]
end

to update-immune ;pessoas procedure
  set immune-duration immune-duration - 1
  if immune? = false [ set color green ]
end

to update-vac
  set vac-duration vac-duration + 1
  if vac-duration = 0 [get-healthy]
end

to spread-sick ;pessoas procedure
  ask other pessoas-here with [virus? = false and immune? = false] [
    ifelse mask? [if random-float 1 < p_inf * 0.25 [ get-sick ]] [if random-float 1 < p_inf [ get-sick ]]
  ]
end

to spread-healthy ;pessoas procedure
  if count other pessoas-here with [virus? = true ] > 0 [
    ifelse mask? [if random-float 1 < p_inf * 0.25 [ get-sick ]] [if random-float 1 < p_inf [ get-sick ]]
  ]
end

to progress ;pessoas procedure
  ifelse incubation? [ set incubation-duration incubation-duration - 1 ]
  [
    ifelse sick? [ set virus-duration virus-duration - 1 set color red ] [ immune-or-die ]
  ]
end

to immune-or-die ;pessoas procedure
  ifelse age < 20 * 52 * 7
  [
    ifelse random-float 100 * ( age / 20 * 52 * 7) < mortality  [ set dead dead + 1 die ] [ set recovered recovered + 1 get-healthy ]
  ]
  [
    ifelse random-float 100 < mortality [ set dead dead + 1 die ] [ set recovered recovered + 1 get-healthy ]
  ]
end

to get-sick ;pessoas procedure
  set virus? true
  set color orange
  set incubation-duration Incubation-time - random (Incubation-time / 3) + random (Incubation-time / 3)
  set virus-duration sick-time - random (sick-time / 2) + random (sick-time / 2)
  set immune-duration 0
  set infected infected + 1
end

to get-healthy ;pessoas procedure
  set virus? false
  set incubation-duration 0
  set color blue
  set immune-duration immunity - random (immunity / 3) + random (immunity / 3)
end

to move ;pessoas procedure
  rt random 90
  lt random 90
  fd 1
end

to reproduce ;pessoas procedure
  if random-float 1 < nat-tax and count other pessoas-here > 0 and count turtles < Maximum-Population
    [ hatch 1
      [
        set age 80 * 52 * 7 + random 10 * 52 * 7 - random 10 * 52 * 7
        lt 90 fd 1
        get-healthy
        set immune-duration 0
        set vac-duration 90
        set color green
        set born born + 1
      ]
  ]
end

to spread-bt ;pessoas procedure
  ask one-of pessoas with [not virus? and not immune?] [ get-sick ]
end

to-report immune? ;pessoas report
  report immune-duration > 0
end

to-report sick? ;pessoas report
  report virus-duration > 0
end

to-report incubation? ;pessoas report
  report Incubation-duration > 0
end

to-report vac? ;pessoas report
  report vac-duration < 90
end
@#$#@#$#@
GRAPHICS-WINDOW
365
10
959
605
-1
-1
4.543
1
10
1
1
1
0
1
1
1
-64
64
-64
64
0
0
1
ticks
30.0

BUTTON
16
54
96
87
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
16
95
96
128
Go_Maxit
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
967
59
1222
209
1/2 Year Plot
Days
Population
0.0
10.0
0.0
10.0
true
true
"" "set-plot-x-range (ticks - 26 * 7) ticks"
PENS
"Sick" 1.0 0 -2674135 true "" "plot count turtles with [virus?]"
"Immune" 1.0 0 -11033397 true "" "plot count turtles with [immune?]"
"Incubating" 1.0 0 -955883 true "" "plot count turtles with [incubation?]"
"Vaccinated" 1.0 0 -5825686 true "" "plot count turtles with [vac?]"
"Masked" 1.0 0 -1184463 true "" "plot count turtles with [mask?]"
"Healthy" 1.0 0 -13840069 true "" "plot count turtles with [not virus? and not immune?]"

SLIDER
16
10
188
43
tick-rate
tick-rate
0
500
10.0
10
1
NIL
HORIZONTAL

BUTTON
100
54
182
87
Spread
spread-bt
NIL
1
T
OBSERVER
NIL
V
NIL
NIL
1

MONITOR
1232
240
1328
285
Mortality_Total
dead
17
1
11

MONITOR
1233
193
1327
238
Recovered_Total
recovered
17
1
11

SLIDER
199
218
356
251
mortality
mortality
0
100
5.0
0.1
1
NIL
HORIZONTAL

SLIDER
198
177
356
210
p_inf
p_inf
0
1
0.85
0.01
1
NIL
HORIZONTAL

SLIDER
14
260
186
293
nat-tax
nat-tax
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
199
350
355
383
immunity
immunity
0
100
90.0
1
1
NIL
HORIZONTAL

MONITOR
1235
336
1330
381
NIL
born
17
1
11

SLIDER
199
309
355
342
Sick-time
Sick-time
0
100
10.0
1
1
NIL
HORIZONTAL

MONITOR
1332
146
1410
191
sick%
count turtles with [virus? and not incubation?] / count turtles * 100
2
1
11

MONITOR
1332
193
1410
238
immune%
count turtles with [immune?] / count turtles * 100
2
1
11

MONITOR
1235
383
1329
428
Years_passed
ticks / 52 / 7
1
1
11

MONITOR
1233
145
1327
190
Infected_Total
Infected
17
1
11

SLIDER
14
174
186
207
Starting-Population
Starting-Population
10
1000
1000.0
10
1
NIL
HORIZONTAL

SLIDER
14
215
186
248
Maximum-Population
Maximum-Population
50
5000
2500.0
10
1
NIL
HORIZONTAL

BUTTON
192
94
277
127
Go_N
repeat n [go]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
284
53
334
126
n
100.0
1
0
Number

BUTTON
101
94
182
127
Go_Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
135
186
168
maxit
maxit
-1
100 * 52
-1.0
52
1
NIL
HORIZONTAL

MONITOR
1332
240
1412
285
healthy%
(count turtles with [not virus? and not immune?] / count turtles * 100)
2
1
11

PLOT
971
395
1226
548
All Time
Days
Population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot count turtles with [virus?]"
"pen-1" 1.0 0 -11033397 true "" "plot count turtles with [immune?]"
"pen-2" 1.0 0 -11085214 true "" "plot count turtles with [not virus? and not immune?]"
"pen-3" 1.0 0 -955883 true "" "plot count turtles with [incubation?]"
"pen-4" 1.0 0 -5825686 true "" "plot count turtles with [vac?]"
"pen-5" 1.0 0 -1184463 true "" "plot count turtles with [mask?]"

SLIDER
199
135
356
168
Starting-infection
Starting-infection
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
1413
147
1505
192
Sick_Now
count turtles with [virus? and not incubation?]
17
1
11

MONITOR
1413
192
1505
237
Immune_Now
count turtles with [Immune?]
17
1
11

MONITOR
1415
240
1506
285
Heallthy_Now
count turtles with [not virus? and not immune?]
17
1
11

MONITOR
1332
335
1412
380
Idade Media
(sum [age] of turtles / count turtles) / 52 / 7
1
1
11

SLIDER
199
263
355
296
Incubation-time
Incubation-time
0
100
7.0
1
1
NIL
HORIZONTAL

MONITOR
1331
99
1410
144
incubating%
count turtles with [incubation?] / count turtles * 100
2
1
11

MONITOR
1413
101
1505
146
Incubating_Now
count pessoas with [incubation?]
17
1
11

MONITOR
1233
98
1328
143
Population
count turtles
0
1
11

SLIDER
200
441
357
474
Mask%
Mask%
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
1415
335
1507
380
pessoas/m^2
count turtles / (max-pxcor * max-pycor)
2
1
11

SLIDER
200
397
356
430
Vax/day
Vax/day
0
2.5
0.0
0.1
1
NIL
HORIZONTAL

MONITOR
1233
288
1328
333
Vaccinated_Total
vaccinated
17
1
11

MONITOR
1332
288
1411
333
Vaccinated%
(count turtles with [vac?] / count turtles * 100)
2
1
11

BUTTON
192
54
275
87
Spread_N
repeat n [spread-bt]
NIL
1
T
OBSERVER
NIL
B
NIL
NIL
1

MONITOR
1415
288
1507
333
Vaccinated_Now
count pessoas with [vac?]
17
1
11

TEXTBOX
198
12
348
51
Desativado ! Tirar de cometario o ciclo while e o timer no metodo go
10
0.0
1

PLOT
968
220
1223
381
5 Years
Days
Population
0.0
10.0
0.0
10.0
true
false
"" "set-plot-x-range (ticks - 5 * 52 * 7) ticks"
PENS
"default" 1.0 0 -2674135 true "" "plot count turtles with [virus?]"
"pen-1" 1.0 0 -13791810 true "" "plot count turtles with [immune?]"
"pen-2" 1.0 0 -955883 true "" "plot count turtles with [incubation?]"
"pen-3" 1.0 0 -5825686 true "" "plot count turtles with [vac?]"
"pen-4" 1.0 0 -1184463 true "" "plot count turtles with [mask?]"
"pen-5" 1.0 0 -13840069 true "" "plot count turtles with [not virus? and not immune?]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.3.0
@#$#@#$#@
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
