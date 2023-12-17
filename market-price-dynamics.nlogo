globals [current-price previous-price return
         current-number-asks current-number-bids order-balance order-book-balance] ; declare of global variables
breed [persons person] ; declare agent
persons-own [talk? bid? ask? volume] ; declare individual properties of the agent

to setup
  clear-all
  setup-variables ; set up the global variables used for computation
  setup-persons ; set up the agents
  reset-ticks
end

to go
  if (ticks > 15000) [stop]
  cancel-orders ; reset the decisions
  make-decision ; create the market speakers and set their decisions
  execute-orders ; execute the orders of the speakers to compute market features
  tick
end

to setup-variables
   set current-price initial-price
   set previous-price initial-price
   set current-number-bids 0
   set current-number-asks 0
   set return [] ;
   set order-book-balance [0];
end

to setup-persons
  create-persons number-agents ; create a given number of persons
  ask persons [
    setxy random-xcor random-ycor
    set color green
    set shape "person"
    set talk? False
    set bid? False
    set ask? False
  ]
end

to make-decision
  ; only a hand of people can intervene in the market
  ask n-of number-speakers persons [
  ifelse random-float 1 <= 0.5 [set talk? False] [set talk? True] ; some of them can decide to actually interve or not
  if talk? [
    set volume 1 + random (max-order-size - 1) ; only when an agent wants to participate, the agent defines the volume he wants to bid or ask
    ifelse random-float 1 <= 0.5
      [set bid? False
       set ask? True
       set color yellow] ; when an agent wants to sell ie speak on the supply side, color him in yellow
      [set bid? True
       set ask? False
       set color red] ; when an agent wants to buy ie speak on the demand side, color him in red
   ]
  ]
end

to execute-orders
  set current-number-bids sum [volume] of persons with [bid? = True] ; compute the total of bids
  set current-number-asks sum [volume] of persons with [ask? = True] ; compute the total of asks
  set order-balance current-number-bids  - current-number-asks ; compute the spread
  set order-book-balance lput order-balance order-book-balance ; monitor all the values of spread

  set previous-price current-price
  set current-price previous-price * exp(order-balance * granularity)

  let current-return ln(current-price) - ln(previous-price) ; get the return of the stock
  set return lput current-return return  ; monitor all its values during the simulation
end

to cancel-orders
  ask persons [
    set color green
    set talk? False
    set bid? False
    set ask? False
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
548
349
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
17
38
189
71
number-agents
number-agents
100
1000
1000.0
20
1
NIL
HORIZONTAL

SLIDER
18
98
190
131
number-speakers
number-speakers
40
200
100.0
10
1
NIL
HORIZONTAL

SLIDER
18
163
190
196
max-order-size
max-order-size
2
200
50.0
6
1
NIL
HORIZONTAL

SLIDER
17
221
189
254
initial-price
initial-price
10
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
18
286
190
319
granularity
granularity
0
0.00005
2.0E-5
0.000002
1
NIL
HORIZONTAL

BUTTON
224
394
288
427
Setup
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
471
398
534
431
Go
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

MONITOR
611
42
685
87
Asset Price
current-price
2
1
11

MONITOR
613
113
741
158
Level of total asks
current-number-asks
0
1
11

MONITOR
614
189
740
234
Level of total bids
current-number-bids
0
1
11

PLOT
963
44
1163
194
Evolution of market price
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot current-price"

PLOT
614
285
814
435
order book balance
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"instantaneous" 1.0 0 -16777216 true "" "plot order-balance"
"mean" 1.0 0 -2674135 true "" "plot mean(order-book-balance)"

PLOT
964
245
1164
395
Market return
NIL
NIL
-0.25
0.25
0.0
15000.0
true
false
"set-histogram-num-bars 10" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram return"

@#$#@#$#@
## WHAT IS IT?

The model’s aim is to represent the price dynamics under very simple market conditions, given the values adopted by the user for the model parameters.

## HOW IT WORKS

The market of a financial asset contains agents on the hypothesis they have zero-intelligence. In each period, a certain amount of agents are randomly selected to participate to the market. Each of these agents decides, in a equiprobable way, between proposing to make a transaction (talk = 1) or not (talk = 0).
Again in an equiprobable way, each participating agent decides to speak on the supply (ask) or the demand side (bid) of the market, and proposes a volume of assets, where this number is drawn randomly from a uniform distribution .

The price of the asset evolves as a function of the excess demand on the market :

               p(t) = p(t-1) * exp((total-bids - total-asks)*eta)

total bids = total volume of assets demanded
total asks = total volume of assets supplied
eta represents the granularity of the market and p0 the initial price .

The granularity depends on various factors, including market conventions, the type of assets or goods being traded, and regulatory requirements. In some markets, high granularity is essential to capture small price movements accurately, while in others, coarser granularity is sufficient due to the nature of the assets or goods being traded

## HOW TO USE IT

### Basic Usage

* SETUP button resets the model
* GO button allows the model to continuously simulate the market

### Parameters

* number-agents slider is used to set the number of people in the market  
* number-speakers is used to set the number of participants trading the stock
* max-order-size slide is used to set the highest volume of assets which can be traded for any participant
* initial-price slider is used to set the initial stock price when the market opens
* granularity slider is used to set the granularity of the market in terms of price adjustment level of detail or precision at which prices are quoted or recorded in a particular market. 

### Plots and monitors

* Asset price monitor checks the final value of price at the end of the simulation
* Level of total bids monitor checks the volume of assets demanded by the participants
* Level of total asks monitor checks the volume of assets supplied by the participants
* Order book balance plot observes the difference between the bid and ask
* Evolution of market price plot observes the price dynamics
* Market return plot checks how distributed the price returns are


## THINGS TO NOTICE

Agents are represented with green turtles when they are not participating. If they participate, then they either turn to red (if they want to buy or speak on the demand side) or yellow (if they want to sell or speak on the supply side)

Notice also that the price return is always distributed normally. Why might this happen ?


## THINGS TO TRY

* Choose one parameter among these ones (granularity , max-order-size , number-speakers with respect to the number-agents) and fix the others to conduct a parametric study : what do you observe in terms of volatility and participants behavior ? 

* Re-assess your study by running the model several times. Is it possible to converge to an equilibrium at each run ?

* Do you think the model can be closed to the financial markets groundtruth ?

## EXTENDING THE MODEL

Try to fine-tune the parameters in order to fit the model with real data from different market types . A two-step approach can be used :

* Check your fine tuning with two assets from the same sector to see if there are common values for some parameters
* Check again with two assets from different sectors to understand the values difference


## RELATED MODELS

It's not really a related model but I found interesting to mention the Limited Order book by Uri Wilensky available in the Model's library . You should check it if you are passionate about trading !!


## CREDITS AND REFERENCES

1. Economy as a complex adaptive system (CAS), Murat Yıldızoglu, Pre-conference workshop on Agent-based Models in Economics and Finance, CEF 2015 Conference, Taipei

2. https://www.investopedia.com/terms/b/bid-and-ask.asp


## HOW TO CITE

If you mention this model or the NetLogo software in a publication, include the citation below.

* Kouajiep Kouega, E. (2023).  NetLogo Market Price Dynamics Model.  https://github.com/edgarkp.


This model was developed as part of the Autumn 2022 Agent-based Modeling course offered by Pr. Georgiy Bobashev at DSTI, Paris. For more info, visit https://www.datasciencetech.institute/fr/applied-msc-in-data-science-ai/.


## COPYRIGHT AND LICENSE

Copyright 2023 Edgar Kouajiep Kouega.

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/edgarkp/NetLogoModels">Market Price Dynamics</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/edgarkp">Kouajiep Kouega Edgar</a> is licensed under <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-SA 4.0</a></p>

![CC BY-NC-SA 4.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)


This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
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
