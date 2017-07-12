;**********************************************************************************************************************
;********************************************                          ************************************************
;********************************************  Soft foraging submodel  ************************************************
;********************************************                          ************************************************
;**********************************************************************************************************************

;*********************************************************
;*******    Space and time specifics of model    *********
;*********************************************************

; Spatial scale: 1500 * 1500 m
; 1 patch = 2 m
; 1 tick = 2 min
; 1 day = 720 ticks
; 1 tick = 2 bites possible for small food; 4 bites possible for large food

;*********************************************************
;*********************   Interface    ********************
;*********************************************************

; Energy cost of individual
; =========================
; Movement-cost:    Cost (J) of moving one patch (2 m). Calculated from DEB model.
; Maintenance-cost: Cost (J) of paying maintenance. Calculated from DEB model.

; Energy gain of individual
; =================
; Low-food gain:  Energy gain (J) from small food items (Brown 1991).
; kap_X:          Converison efficiency of assimilated energy from food (J) (Kooijman 2010).

; Food patch growth
; =================
; Food-growth:        Growth of plant material (J) per tick (Norman et al. 2008).
; Large-food-initial: Initial energy level (J) of large food items at setup. Parameterised from literature.
; Small-food-initial: Initial energy level (J) of small food items at setup. Parameterised from literature.

; Individual attributes
; ===================
; Maximum-reserve: Maximum reserve level (J). Appears in 'to setup' and 'to make decision'.
; Minimum-reserve: Define the critical starvation period. Individuals can survive without food for two hours in this state (reasonable estimate). The threshold of reserve that induces the increasing visual scope of the individual. Vision increases by 2 patches every tick to the maximum vision range (10 patches (20 m)).

;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; extensions [r]  ; Extension for calling R commands from NetLogo

globals
[
  in-shade?          ; Reports TRUE if turtle is in shade
  in-food?           ; Reports TRUE if turtle is in a food patch
  min-energy         ; Minimum food unit level for individual to lose interest and move away from patch. This eliminates the incentive for individuals to return immediately to the previously visited food patch after vacating it.
  reserve-level      ; Reserve level of individual.
  min-vision         ; Minimum (normal) vision range of individuals (Auburn et al. 2009).
  max-vision         ; Maximum vision range of individuals activated by starvation mode. See 'to starving' procedure (Auburn et al. 2009)
  ctmincount         ; Counter for time spent under min_T_b_
  feedcount          ; Counter for time spent in feeding state.
  restcount          ; Counter for the time spent resting in shade
  searchcount        ; Counter for time spent searching for food.
  starvecount        ; Counter for time spent in starvation state.
  shadecount         ; Counter for time spent searching for shade following a feeding bout.
  transcount         ; Counter for frequency of transitions between any of the three activity states--searching, feeding, resting.
  zenith             ; Zenith angle of sun (update-sun procedure).
  tempX
  tempY
  tempXY
  gutfull            ; Reports gut level of DEB model
  movelist           ; List of cumulative movement costs
  fh_                ; String for working dir to export results
  ;Shade-density      ; Choose between randomly distributed or randomly clumped shade patches in landscape
  ]

turtles-own
[
  activity-state     ; Individual is either under a Searching, Feeding, or Resting state for each tick. The transition between the various activity states defines the global behavioural repetoire.
  energy-gain        ; Converted energy gained from food
;  high-energy-gain   ; Converted energy gained from large food items
;  search-energy      ; Minimum reserve that satisficing individual reaches to stop resting and start searching. Defined in Setup as fraction of total reserve. This is the crux of the satisficing strategy--rest only until food is needed.
  ;T_b_init_         ; Initial body temperature (T_b_init) of individual (Celcius)
  T_b_               ; Body temperature (T_b) of individual (Celcius)
  T_b_basking_       ; Basking body temperature of individual (Celcius)
  T_opt_range        ; Foraging body temperature range of individual (Celcius)
  T_opt              ; Median foraging body temperature of individual (Celcius)
  T_opt_lower_        ; Lower foraging body temperature of individual (Celcius)
  T_opt_upper_        ; Upper foraging body temperature of individual (Celcius)
  min-T_b_           ; Lower critical body temperature (min-T_b) of individual (Celcius)
  max-T_b_           ; Upper critical body temperature (max-T_b) of individual (Celcius)
  vision-range       ; Vision (no. of patches) range of individual.
  ;strategy_         ; *> Interface <* Defines the foraging strategy of individual. This is set in the Interface and is thus masked in the code.
  has-been-starving? ; Results reporter only variable for reporting stavation time only if individual has starved
  has-been-feeding?  ; Results reporter only variable for reporting feeding time only if individual has been feeding
  X                  ; List of x coords for homerange
  Y                  ; List of y coords for homerange
  gutthresh_         ; Threshold for gutlevel to motivate turtle to move
  V_pres_            ; DEB structural volume
  wetgonad_          ; DEB wet mass reproductive organ volume
  wetstorage_        ; DEB wet mass storage
  wetfood_
  hungerstate
  thermalstate
  matestate
  fearstate
  ]

patches-own
[
  patch-type    ; Defines type of patches in environment as either Food or Shade.
  food-level    ; *> Interface <* Defines the initial and updated level of energy (J) in food patches. Food level increases (plant growth; see 'Food patch growth' in Interface) and decreases (feeding by individual) with each tick.
  shade-level   ; *> Interface <* Defines the initial and updated level of shade in shade patches. Shade levels remain constant throughout simulation.
  ]

breed
[suns sun]
breed
[homeranges homerange]

;********************************************************************************************************************
;***********************************************      SETUP      ****************************************************
;********************************************************************************************************************

to setup
  ca
  if Food-patches + Shade-patches > count patches
  [ user-message (word "Lower the sum of shade and food patches to < " count patches ".")
    stop ]
  random-seed 1                          ; Outcomment to generate seed for spatial configuration of all patches in the landscape (food and shade). For reproducibility. NB: turtle movement is still stochastic. See below random-seed primitive for complete function.
  set min-energy Small-food-initial
  set min-vision 5                         ; 10m (Auburn et al. 2009)
  set max-vision 10                        ; 20m (Auburn et al. 2009)

  ask patches
  [set patch-type "Sun"
    set pcolor (random 1 + blue)]

  let NumFoodPatches Food-patches / 10
  ask n-of NumFoodPatches patches [
    ask n-of 10 patches in-radius 4 [ ; Sets 10 random food patches within a 5-patch radius of Food-patches
    let food-amount random 100
    ifelse food-amount < 50
    [set food-level (Small-food-initial) + random-float 1 * 10 ^ -5] ; Makes only one food patch attractive to turtle
    [set food-level (Large-food-initial) + random-float 1 * 10 ^ -5]
      set pcolor PatchColor
      set patch-type "Food"
      ]
  ]

ifelse Shade-density = "Random"[ ; chooser for setting Random or Clumped shade patches (similar to food patch arrangement)
  let NumShadePatches Shade-patches
  ask n-of NumShadePatches patches [
    let shade-amount random 100
    ifelse shade-amount < 50
    [set shade-level (Low-shade + random-float 1 * 10 ^ -5) ; Makes only one shade patch attractive to turtle
      set pcolor black + 2]
    [set shade-level (High-shade + random-float 1 * 10 ^ -5)
      set pcolor black]
      set patch-type "Shade"
      ]
]
[
    let NumShadePatches Shade-patches / 10
    ask n-of NumShadePatches patches [
    ask n-of 10 patches in-radius 4 [ ; Sets 10 random food patches within a 5-patch radius of Food-patches
    let shade-amount random 100
    ifelse shade-amount < 50
    [set shade-level (Low-shade + random-float 1 * 10 ^ -5) ; Makes only one shade patch attractive to turtle
      set pcolor black + 2]
    [set shade-level (High-shade + random-float 1 * 10 ^ -5)
      set pcolor black]
      set patch-type "Shade"
      ]
]
]; close else shade loop


ask patch 0 0 [set patch-type "Shade"
  set pcolor black]

set movelist (list 0)
;  ask one-of patches with [patch-type = "Shade"]
;  [sprout 1]
crt 1

 random-seed new-seed                    ; Outcomment to generate seed for spatial configuration of all patches in the landscape (food and shade).

  ask turtle 0
  [
    setxy 0 0 ;random-xcor random-ycor
    set reserve-level Maximum-reserve
    set T_b_basking_ 14
    set T_opt_range (list 26 27 28 29 30 31 32 33 34 35 )        ; From Pamula thesis
    set T_opt_upper last T_opt_range
    set T_opt_lower first T_opt_range
    set T_opt median T_opt_range
    set min-T_b_ min-T_b
    set max-T_b_ max-T_b
    set V_pres_ V_pres
    set wetgonad_ wetgonad
    set wetstorage_ wetstorage
    set wetfood_ wetfood
    set activity-state "S"
    ;set strategy_ Strategy
    set vision-range min-vision
    if [patch-type] of patch-here = "Shade"
    [set in-shade? TRUE]
     if [patch-type] of patch-here = "Food"
    [set in-food? TRUE]
    set shape "lizard"
    set size 2
    set color red
    pen-down
    set X (list xcor)
    set Y (list ycor)
    ]
setup-spatial-plot
set fh_ fh
;create-sun
reset-ticks
;r:clear                                  ; extensions [r] command. Outcomment if calling R from Netlogo.
end

;********************************************************************************************************************
;***********************************************      GO        *****************************************************
;********************************************************************************************************************

to go
  tick
  if not any? turtles
  [
    get-homerange
    print "All turtles dead. Check output of model results."
    repeat 3 [beep wait 0.2]
    stop
    save-world
    ]
  if (ticks * 2 / 60 / 24) = No.-of-days
  [
    ask turtle 0
    [report-results]
    save-plots
    stop
    save-world
    ]
  ifelse show-plots?
  []
  [clear-all-plots]
  ask turtle 0
  [
    report-patch-type
 ;   set reserve-level reserve-level - Maintenance-cost
    ask turtles with [reserve-level > Minimum-reserve]
    [set vision-range min-vision]
    update-T_b
    ;if (activity-state = "R" and [patch-type] of patch-here != "Shade")
;    [shade-search]
    make-decision
    update-wetmass
;    if activity-state = "R" and [patch-type] of patch-here = "Shade"
;    [rest]
    set X lput xcor X ; populate X list with turtle's X coords to generate home range
    set Y lput ycor Y ; populate Y list with turtle's Y coords to generate home range
  ]
  if any? turtles with [reserve-level <= 0]
  [ask turtle 0 [report-results]
    stop
    ]
  ask patches with [patch-type = "Food"]
    [update-food-levels]
  ;update-sun
end

;*****************************************************************************************************************************
;*************************************************    TO UPDATE T_b     ******************************************************
;*****************************************************************************************************************************

to update-T_b
  ask turtles with [T_b >= max-T_b]
    [stop]
  if T_b <= min-T_b
    [set ctmincount ctmincount + 1]
    if (ctmincount * 2 / 60) = ctminthresh
    [stop]
end

;*****************************************************************************************************************************
;*************************************************    TO MAKE DECISION      **************************************************
;*****************************************************************************************************************************

to make-decision

;-------------------------------------------------------------------------------------
;-------------------------------------Optimising-------------------------------------
;-------------------------------------------------------------------------------------
  ifelse (strategy = "Optimising")
  [; start optimising loop
    ifelse (T_b > T_opt_upper) or (T_b < T_opt_lower)
  [
    ask turtle 0
    [;set label "Resting"
      set activity-state "R"
;      ifelse gutfull >= gutthresh and T_b < T_opt_upper and T_b > T_opt_lower
;      [;set label "Full gut"
;        stop ]
;      [
      if [patch-type] of patch-here != "Shade"
      [shade-search]
;     ] ;close else loop for ifelse gutthresh and T_b conditional above
      if ([patch-type] of patch-here = "Shade") and (T_b < T_b_basking_)
      [set in-shade? TRUE
        set in-food? FALSE]
      ]
    if (activity-state = "R") and (T_b >= T_b_basking_) and (T_b < T_opt_upper) ; Basking behaviour
    [set in-shade? FALSE
      set in-food? FALSE
 ;      set transcount transcount + 1 ; Outcomment to include basking behaviour as activity state
 ;      plotxy xcor ycor
    ]
 set restcount restcount + 1
    ]
     [; else optimising loop
        if (activity-state = "R")
    [
        set restcount restcount + 1
       ; set label "Resting"
      if ((T_b <= T_opt_upper) and (T_b >= T_opt_lower)); and reserve-level < search-energy
      [set transcount transcount + 1
        plotxy xcor ycor
        set activity-state "S"]
     ; [set activity-state "R"]
    ]

                               ; 28-11-14: Only works with maint. or movement costs, otherwise reserve level = Max. reserve and turtle chooses to rest
    if (activity-state = "F"); Use this procedure to eliminate turtle returning to shade patch after every feeding bout and to eliminate min-energy parameter. Using min-energy will cause problems in model with soil moisture profile updating food growth.
    [                          ; Turning empty food patches into Sun patches elimates the need for min-energy.
      ifelse (gutfull < gutthresh) ;and ([patch-type] of patch-here = "Food") ; if gut is not full, keep feeding
      [
      ask turtle 0
      [handle-food
        ;set label "Feeding"
        set has-been-feeding? TRUE]
      if [patch-type] of patch-here != "Food" ; if patch isn't food, search for food
      [set activity-state "S"
        set transcount transcount + 1
        plotxy xcor ycor
        set energy-gain 0]
      if reserve-level >= Maximum-reserve ; turtle will fight between feeding and resting if DEB model not activated i.e. reserve incurs no cost.
      [set transcount transcount + 1
        plotxy xcor ycor
;        ifelse (strategy = "Optimising")
;        [set activity-state "S"]
        set activity-state "R"
        stop]
      ]
      [;set label "Gut is full" ; otherwise, turtle moves during active hours of the day
        socialise
        set searchcount searchcount + 1
        set in-food? FALSE
        plotxy xcor ycor
        ]
    ]

    if (activity-state = "S")
    [
      ask turtle 0
      [search
       ; set label "Searching for food"
       ]
      set searchcount searchcount + 1
      set in-food? FALSE
      if ([patch-type] of patch-here = "Food") and (gutfull < gutthresh) ;and ([food-level] of patch-here > min-energy)
      [set transcount transcount + 1
        plotxy xcor ycor
        set activity-state "F"]
      ]
  ]
  ]; end optimising loop



;-------------------------------------------------------------------------------------
;-------------------------------------Satisficing-------------------------------------
;-------------------------------------------------------------------------------------

  [; else satisfice, i.e. move only when gutfull is below the gut threshold
  ifelse (T_b > T_opt_upper) or (T_b < T_opt_lower) or (gutfull >= gutthresh); 'gutfull' is DEB.R input
  [
    ask turtle 0
    [;set label "Resting"
      set activity-state "R"
      ifelse gutfull >= gutthresh and T_b < T_opt_upper and T_b > T_opt_lower
      [;set label "Full gut"
        stop ]
      [if [patch-type] of patch-here != "Shade"
      [shade-search]]
      if ([patch-type] of patch-here = "Shade") and (T_b < T_b_basking_)
      [set in-shade? TRUE
        set in-food? FALSE]
      ]
    if (activity-state = "R") and (T_b >= T_b_basking_) and (T_b < T_opt_upper) ; Basking behaviour
    [set in-shade? FALSE
 ;      set transcount transcount + 1 ; Outcomment to include basking behaviour as activity state
 ;      plotxy xcor ycor
    ]
 set restcount restcount + 1
    ]

  [
        if (activity-state = "R")
    [
        set restcount restcount + 1
       ; set label "Resting"
      if ((T_b <= T_opt_upper) and (T_b >= T_opt_lower)); and reserve-level < search-energy
      [set transcount transcount + 1
        plotxy xcor ycor
        set activity-state "S"]
     ; [set activity-state "R"]
    ]


    if (activity-state = "F")
    [
      ifelse (gutfull < gutthresh) ;and ([patch-type] of patch-here = "Food") ; if gut is not full, keep feeding, else stop.
      [
      ask turtle 0
      [handle-food
        ;set label "Feeding"
        set has-been-feeding? TRUE]
      if [patch-type] of patch-here != "Food"
      [set activity-state "S"
        set transcount transcount + 1
        plotxy xcor ycor
        set energy-gain 0]
      if reserve-level >= Maximum-reserve ; Turtle will fight between feeding and resting if DEB model not activated i.e. reserve incurs no cost.
      [set transcount transcount + 1
        plotxy xcor ycor
;        ifelse (strategy = "Optimising")
;        [set activity-state "S"]
        set activity-state "R"
;        set restcount restcount + 1 ; part of regular restcount because satisficing animals rest in open sun
        stop]
      ]
      [;set label "Gut is full"
        stop]
    ]

    if (activity-state = "S")
    [
      ask turtle 0
      [search
       ; set label "Searching for food"
       ]
      set searchcount searchcount + 1
      set in-food? FALSE
      if ([patch-type] of patch-here = "Food")  ;and ([food-level] of patch-here > min-energy)
      [set transcount transcount + 1
        plotxy xcor ycor
        set activity-state "F"]
      ]
    ]
  ]; end satisficing loop

end

;**********************************************************************************************************************
;***********************************************     TO SEARCH      ***************************************************
;**********************************************************************************************************************

to search
  set reserve-level reserve-level - Movement-cost ; add miniscule movement cost to avoid turtle exiting green food patches for one time step when feeding
  set movelist lput Movement-cost movelist
  bounce
  let local-food-patches patches with [(distance myself < [vision-range] of turtle 0) and (patch-type = "Food")]
  ifelse any? local-food-patches
  [let my-food-patch local-food-patches with-min [distance myself] ;with-max [food-level]
  face one-of my-food-patch]
  [lt random 180 - 90 ]
  fd 1
  if [patch-type] of patch-here = "Food"
  [set activity-state "F"]
end

;**************************************************************************************************************************
;**********************************************    TO BOUNCE     **********************************************************
;**************************************************************************************************************************

to bounce
                  ;; Turtles turn a random angle ~180 when encountering a wall
  ask turtle 0
 [ if abs pxcor = abs max-pxcor or
      abs pycor = abs max-pycor
    [lt random-float 180 ]
 ]
end

;**************************************************************************************************************************
;**********************************************    TO HANDLE FOOD      ****************************************************
;**************************************************************************************************************************

to handle-food
  set energy-gain Low-food-gain
  set in-food? TRUE
  set in-shade? FALSE
  set feedcount feedcount + 1
  set-current-plot "Spatial coordinates of transition between activity states"
  set-current-plot-pen "Feeding"
  ifelse [pcolor] of patch-here = 45
  [set-plot-pen-color 45]
  [set-plot-pen-color 55]
  plotxy xcor ycor
end

;**************************************************************************************************************************
;********************************************     TO SHADE SEARCH       ***************************************************
;**************************************************************************************************************************

to shade-search
;  set activity-state "S"
  set reserve-level reserve-level - Movement-cost ; add miniscule movement cost to avoid turtle exiting green food patches for one time step when feeding
  set movelist lput Movement-cost movelist
  let local-shade-patches patches with [(distance myself < [vision-range] of turtle 0) and (patch-type = "Shade")]
  ifelse any? local-shade-patches
  [let my-shade-patch local-shade-patches with-min [distance myself] with-max [shade-level]
    face one-of my-shade-patch
    set shadecount shadecount + 1]
  [lt random 180 - 90]
  fd 1
 ; set label "Searching for shade"
;  if [patch-type] of patch-here = "Shade"
;  [set activity-state "R"]
end

;**************************************************************************************************************************
;*********************************************       TO REST      *********************************************************
;**************************************************************************************************************************

to rest
  ifelse strategy = "Optimising"
  [set activity-state "S"]
  [set activity-state "R"]
end

;**************************************************************************************************************************
;*********************************************       TO STARVE       ******************************************************
;**************************************************************************************************************************

to starving
 set vision-range vision-range + (max-vision / 6)
 ask turtle 0
 [set label "Starving"
 print "I'm starving"
 set has-been-starving? TRUE]
end

;**************************************************************************************************************************
;*********************************************       TO SOCIALISE       ***************************************************
;**************************************************************************************************************************

to socialise
  set reserve-level reserve-level - Movement-cost ; add miniscule movement cost to avoid turtle exiting green food patches for one time step when feeding
  set movelist lput Movement-cost movelist
  bounce
  lt random 180 - 90
  fd 1
  if gutfull < gutthresh
  [set activity-state "S"]
end

;*********************************************************************************************************************************
;***********************************************     TO UPDATE FOOD LEVELS     ***************************************************
;*********************************************************************************************************************************

to update-food-levels
  let food-deplete food-level - Low-food-gain
  if (count turtles-here with [activity-state = "F"] > 0) and (gutfull < gutthresh)
; [ifelse food-level < Large-food-initial
  [set food-level food-deplete ; yellow food
    set in-food? TRUE
    print "In food"]
;  [set food-level food-level - (Low-food-gain * 2)] ; green food
;  ]
;[set food-level food-level + Food-growth]      ; growing food
  if food-level < Small-food-initial
    [set patch-type "Sun"]
set pcolor PatchColor
end


;*********************************************************************************************************************************
;***********************************************     TO UPDATE WETMASS     *******************************************************
;*********************************************************************************************************************************

to update-wetmass
;  set V_pres_ V_Pres
;  plotxy xcor ycor
;  set wetstorage_ wetstorage
;  plotxy xcor ycor
;  set wetfood_ wetfood
;  plotxy xcor ycor
;  set wetgonad_ wetgonad
;  plotxy xcor ycor
end

;*********************************************************************************************************************************
;***********************************************    TO REPORT PATCH COLOUR     ***************************************************
;*********************************************************************************************************************************

to-report PatchColor
  let PatColor 0
  ifelse food-level >= Large-food-initial
  [set PatColor green]
  [ifelse food-level >= Small-food-initial
    [set PatColor yellow]
    [set PatColor brown]
  ]
  report PatColor
end

;*********************************************************************************************************************************
;***********************************************    TO REPORT PATCH-TYPE     *****************************************************
;*********************************************************************************************************************************

to report-patch-type
ifelse [patch-type] of patch-here = "Food"
    [set in-food? TRUE]
    [
      ifelse [patch-type] of patch-here = "Shade"
      [set in-shade? TRUE]
      [set in-shade? FALSE
        set in-food? FALSE]
    ]
end

;*********************************************************************************************************************************
;***********************************************     TO REPORT RESULTS     *******************************************************
;*********************************************************************************************************************************

to report-results
    output-print (word "Number of real days:,, " precision (ticks * 2 / 60 / 24) 5)
    output-print ""
    output-print (word "Time spent searching for food (mins/days):, " (searchcount * 2) " , " precision (searchcount * 2 / 60 / 24) 3 "")
    output-print ""
    output-print (word "Time spent feeding (mins/days):, " (feedcount * 2) " , " precision (feedcount * 2 / 60 / 24) 3 "")
    output-print ""
    output-print (word "Time spent searching for shade  (mins/days):, " (shadecount * 2) " , " precision (shadecount * 2 / 60 / 24) 3 "")
    output-print ""
    output-print (word "Time spent resting in shade (mins/days):, " (restcount * 2) " , " precision (restcount * 2 / 60 / 24) 3 "")
    output-print ""
    output-print (word "Time spent in critical starvation (mins/days):, " (starvecount * 2) " , " precision (starvecount * 2 / 60 / 24) 3 "")
    output-print ""
    output-print (word "Number of transitions between activity states:, " transcount)
    output-print ""
    ifelse has-been-feeding? = TRUE
    [output-print (word "Proportion of feeding to searching:, " precision (feedcount / searchcount) 3)]
    [output-print (word "Proportion of feeding to searching:, " 0)]
    output-print ""
    ifelse has-been-starving? = TRUE
    [output-print (word "Proportion of feeding to starving:, " precision (feedcount / starvecount) 3)]
    [output-print (word "Proportion of feeding to starving:, " 0)]
    output-print ""
    output-print (word "Patches with pcolor = brown (eaten): " patches with [pcolor = 35])
    stop;die

end

;*********************************************************************************************************************************
;***********************************************     TO SAVE WORLD     ***********************************************************
;*********************************************************************************************************************************

to save-world                          ; This procedure saves the model world. The file output procedure then outputs the saved model world as a .txt file to the Desktop.
  let world user-new-file
  if ( world != false )
  [
    file-write world
    ask patches
    [
      file-write pxcor
      file-write pycor
       if patch-type = "Food"
       [file-write pxcor and pycor and (patch-type = "Food") and food-level]
       if patch-type = "Shade"
       [file-write pxcor and pycor and (patch-type = "Shade") and shade-level]
    ]
    file-close
  ]
end

to save-plots

;export-plot "Spatial coordinates of transition between activity states" "/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/spatialplottest.csv"
end

;*********************************************************************************************************************************
;***********************************************         SPATIAL PLOT         ****************************************************
;*********************************************************************************************************************************

to setup-spatial-plot
  set-current-plot "Spatial coordinates of transition between activity states"
  set-plot-x-range min-pxcor max-pxcor
  set-plot-y-range min-pycor max-pycor
  clear-plot
end


;*********************************************************************************************************************************
;***********************************************         GET HOMERANGE         ***************************************************
;*********************************************************************************************************************************

to get-homerange
;r:eval "library(adehabitatHR)" ; load the r packages
;r:eval "library(sp)"
;
;r:eval "turtles<-data.frame()" ; make an empty data frame
;
;ask turtle 0
;[
;  (r:putdataframe "turtle" "X" X "Y" Y) ; put the X and Y coords into a dataframe
;  r:eval (word "turtle<-data.frame(turtle,ID = '"ID"')")
;  r:eval "turtles<-rbind(turtles,turtle)"
;  ]
;
;r:eval "spdf<-SpatialPointsDataFrame(turtles[1:2], turtles[3])" ; creates a spatial points data frame (adehabitatHR package)
;r:eval "homerange<-mcp(spdf)"

draw-homerange
save-homerange
;plot-area

end

;*********************************************************************************************************************************
;***********************************************         DRAW HOMERANGE         **************************************************
;*********************************************************************************************************************************

to draw-homerange
  clear-drawing
  if any? turtles [
    ask turtle 0
  [
   pu
   ; calculate homerange points
;   r:eval (word "temp <- slot(homerange,'polygons')[[which(slot(homerange,'data')$id == '"ID"')]]@Polygons[[1]]@coords")
;   set tempX tempX
;   set tempY tempX
;   set tempXY tempXY

   ; hatch a turtle to draw the homerange boundary points
   hatch-homeranges 1
   [
     hide-turtle
 ;    set ID [ID] of myself
     set color red
     ]

   ; draw the homerange
   foreach tempXY
   [
     ask homeranges
     [
       move-to patch (item 0 ?) (item 1 ?)
       pd
       ]
     ]

   ; close the homerange polygon
   ask homeranges
   [
     let lastpoint first tempXY
     move-to patch (item 0 lastpoint) (item 1 lastpoint)
     ]
  ]
  ]
end

;*********************************************************************************************************************************
;***********************************************         SAVE HOMERANGE         **************************************************
;*********************************************************************************************************************************

to save-homerange

  ; save the homerange polygon into a pdf
;  r:eval (word "pdf('" Homerange-poly_dir ".pdf')" )
;  r:eval (word "plot(homerange, xlim=c(" min-pxcor "," max-pxcor "), ylim=c(" min-pycor "," max-pycor "))")
;  r:eval "plot(spdf,col=as.data.frame(spdf)[,1],add=T)"
;  r:eval "dev.off()"
;
;  ; save a plot of the homerange area level into a pdf
;  r:eval (word "pdf('"Homerange-plot_dir".pdf')")
;  r:eval "plot(mcp.area(spdf,unout='m2'))"
; ; r:eval (word "plot(mcp.area(spdf,unout='m2'), main=Homerange polygon for "No.-of-days" days with "Shade-patches" shade and "Food-patches" food patches)")
;  r:eval "dev.off()"

end


;*********************************************************************************************************************************
;***********************************************         CREATE AND UPDATE SUN         *******************************************
;*********************************************************************************************************************************

to create-sun
  create-suns 1
  [
    set shape "orbit 1" ;"clock"
    set size 5
    set color yellow
    setxy (max-pxcor - 3) (max-pycor - 3)
    set heading 270
    set label (word 0 "  " "days")
    set heading zenith
    set label zenith
    ]
end

to update-sun
  ask suns
  [set heading heading + 0.5
    set label (word precision (ticks * 2 / 60 / 24) 1 "  " "days")
    ifelse (heading > 270) or (heading < 90)
    [set shape "orbit 1"
      set color yellow]
    [set shape "moon zenith"
      set size 5
      set color [pcolor] of patch-here]
    set heading zenith
    set label ticks
  ]
end

;*********************************************************************************************************************************
;*******************************************           REFERENCES         ********************************************************
;*********************************************************************************************************************************

; Auburn, Z. M., Bull, C. M. and Kerr G. D. (2009) The visual perceptual range of a lizard, Tiliqua rugosa, J. Ethol. 27:75-81.
; Brown, G. W. (1991) Ecological feeding analysis of south-eastern Australian Scincids  (Reptilia--Lacertilia), Aust. J. Zool. 39:9-29.
; Kooijman, S. A. L. M. (2010) Dynamic Energy Budget theory for metabolic organisation. Cambridge University Press.
; Norman, H. C., Mayberry, D. E., McKenna, D. J., Pearce, K. L. & Revell D. K. (2008) Old man saltbush in agriculture: feeding value for livestock production systems, 2nd International Salinity Forum: Salinity, water and society--global issues, local action.
; Pamula Y (1997) Ecological and physiological aspects of reproduction in the viviparous skink Tiliqua rugosa, Ph.D. thesis, Flinders University.
@#$#@#$#@
GRAPHICS-WINDOW
386
10
1155
800
375
375
1.011
1
10
1
1
1
0
0
0
1
-375
375
-375
375
1
1
1
ticks
30.0

BUTTON
7
502
70
535
NIL
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
136
502
217
535
go once
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

BUTTON
72
502
135
535
NIL
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
804
856
939
901
Time spent feeding
feedcount
17
1
11

PLOT
1165
762
1645
1011
Total wetmass plot
Time
Total wetmass
0.0
10.0
0.0
10.0
true
true
"" "let total 0\n\nset-current-plot-pen \"V_pres\"\nplot-pen-up plotxy ticks total\nset total V_pres + total \nplot-pen-down plotxy ticks total\n\nset-current-plot-pen \"wetstorage\"\nplot-pen-up plotxy ticks total\nset total wetstorage + total \nplot-pen-down plotxy ticks total\n\n\nset-current-plot-pen \"wetfood\"\nplot-pen-up plotxy ticks total\nset total wetfood + total\nplot-pen-down plotxy ticks total\n\nset-current-plot-pen \"wetgonad\"\nplot-pen-up plotxy ticks total\nset total wetgonad + total\nplot-pen-down plotxy ticks total"
PENS
"V_pres" 1.0 0 -955883 true "" ""
"wetstorage" 1.0 0 -6459832 true "" ""
"wetfood" 1.0 0 -13840069 true "" ""
"wetgonad" 1.0 0 -5825686 true "" ""

OUTPUT
424
960
868
1267
13

INPUTBOX
6
572
111
632
Movement-cost
1.0E-9
1
0
Number

INPUTBOX
118
571
223
631
Maintenance-cost
43.612
1
0
Number

INPUTBOX
10
758
91
818
Food-growth
30
1
0
Number

TEXTBOX
8
546
158
564
Energy cost of individual
12
0.0
0

TEXTBOX
11
737
122
755
Food patch growth
12
0.0
0

INPUTBOX
9
666
100
726
Low-food-gain
3000
1
0
Number

TEXTBOX
8
642
158
660
Energy gain of individual
12
0.0
0

INPUTBOX
173
852
273
912
Minimum-reserve
100
1
0
Number

TEXTBOX
12
829
130
847
Individual attributes
12
0.0
1

INPUTBOX
97
758
201
818
Large-food-initial
6000
1
0
Number

INPUTBOX
207
759
311
819
Small-food-initial
3000
1
0
Number

PLOT
1165
10
1642
254
Reserve level and starvation reserve over time
Time
Reserve (J/cm^3)
0.0
10.0
0.0
10.0
true
true
"" ";let t reserve-plot-range \n;if ticks > t                               \n;[set-plot-x-range (ticks - t) ticks]"
PENS
"Reserve level" 1.0 0 -16777216 true "" "if any? turtles\n[plot [reserve-level] of turtle 0]"
"Starvation reserve" 1.0 0 -5298144 true ";plot Minimum-reserve\nauto-plot-off\nplotxy 0 Minimum-reserve \nplotxy 100000000 0\nauto-plot-on" ""

TEXTBOX
7
137
157
155
Individual characteristics\n
12
0.0
0

TEXTBOX
7
12
215
134
*********************************\n**********  Instructions **********\n*********************************\n\n1. Set the foraging strategy of the \n    individual using the chooser. \n    Read the notes within the Info \n    tab to learn about the strategies.
12
125.0
1

TEXTBOX
8
463
239
492
4. 'Setup' generates the landscape. \n    'Go' runs the model. \n\n
12
125.0
1

INPUTBOX
6
257
98
317
Shade-patches
100000
1
0
Number

INPUTBOX
100
257
190
317
Food-patches
100000
1
0
Number

TEXTBOX
7
212
303
242
2. Define the number of food and shade patches \n    in the landscape, and the simulation length.
12
125.0
1

TEXTBOX
425
932
790
962
Output of model results.
12
0.0
1

INPUTBOX
12
852
167
912
Maximum-reserve
7222.30069902594
1
0
Number

PLOT
1165
517
1644
754
Global time budget
Time
Frequency of activity states
0.0
10.0
0.0
10.0
true
true
"" "let total 0\n\nset-current-plot-pen \"Starving\"\nplot-pen-up plotxy ticks total\nset total starvecount + total \nplot-pen-down plotxy ticks total\n\nset-current-plot-pen \"Resting\"\nplot-pen-up plotxy ticks total\nset total restcount + total \nplot-pen-down plotxy ticks total\n\n\nset-current-plot-pen \"Transcount\"\nplot-pen-up plotxy ticks total\nset total transcount + total\nplot-pen-down plotxy ticks total\n\nset-current-plot-pen \"Searching\"\nplot-pen-up plotxy ticks total\nset total searchcount + total\nplot-pen-down plotxy ticks total\n\nset-current-plot-pen \"Feeding\"\nplot-pen-up plotxy ticks total\nset total feedcount + total\nplot-pen-down plotxy ticks total\n\n;let t2 time-budget-range\n;if ticks > t2         \n;[set-plot-x-range (ticks - t2) ticks]"
PENS
"Feeding" 1.0 1 -10899396 true "" ""
"Searching" 1.0 1 -13345367 true "" ""
"Transcount" 1.0 1 -7500403 true "" ""
"Resting" 1.0 1 -16777216 true "" ""
"Starving" 1.0 1 -2674135 true "" ""

PLOT
1647
11
2104
254
Spatial coordinates of transition between activity states
Xcor
Ycor
-25.0
25.0
-25.0
25.0
true
false
"set-plot-pen-mode 2\n;set-plot-pen-interval 5" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""
"Feeding" 1.0 2 -10899396 true "" ";ask turtle 0 [\n;if ([patch-type] of patch-here = \"Food\") and (activity-state = \"F\")\n;[plotxy xcor ycor]\n;]\n\n; current working version 30-4-15 \n;ask turtle 0 [\n;if activity-state = \"F\"\n;[plotxy xcor ycor]\n;]\n\n;ask turtles with [activity-state = \"F\"] [\n;if [patch-type] of patch-here = \"Food\"\n;[plotxy xcor ycor]\n;]"
"Searching" 1.0 0 -13345367 true "" ";ask turtle 0 [if (activity-state = \"S\") or (activity-state = \"F\") or (activity-state = \"R\")\n;[plotxy xcor ycor]\n;]\n\nask turtle 0 [plotxy xcor ycor]"
"Resting" 1.0 2 -16777216 true "" "ask turtle 0 [\nif [patch-type] of patch-here = \"Shade\" \n[plotxy xcor ycor]\n]"

MONITOR
476
857
610
902
Number of transitions
transcount
17
1
11

SWITCH
201
173
319
206
show-plots?
show-plots?
0
1
-1000

MONITOR
615
806
798
851
Time spent searching for food
searchcount
17
1
11

MONITOR
614
857
798
902
Time spent searching for shade
shadecount
17
1
11

INPUTBOX
12
948
88
1008
Low-shade
10
1
0
Number

INPUTBOX
94
948
173
1008
High-shade
90
1
0
Number

TEXTBOX
13
924
95
942
Shade levels
12
0.0
1

INPUTBOX
194
257
273
317
No.-of-days
5
1
0
Number

PLOT
1166
262
1641
507
Body temperature (T_b)
Time
Body temperature
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "set-plot-y-range 0 max-T_b + 5" "if any? turtles\n[plot [T_b] of turtle 0]"
"T_opt_lower" 1.0 0 -2674135 true "auto-plot-off\nplotxy 0 [T_opt_lower] of turtle 0\nplotxy 1000000000 [T_opt_lower] of turtle 0\nauto-plot-on" ""
"T_opt_upper" 1.0 0 -2674135 true "auto-plot-off\nplotxy 0 [T_opt_upper] of turtle 0\nplotxy 1000000000 [T_opt_upper] of turtle 0\nauto-plot-on" ""

INPUTBOX
79
389
157
449
T_opt_lower
26
1
0
Number

INPUTBOX
9
389
74
449
T_b
26
1
0
Number

INPUTBOX
160
389
239
449
T_opt_upper
35
1
0
Number

TEXTBOX
10
365
230
395
Body temperature (T_b) of individual
12
0.0
1

TEXTBOX
9
328
284
358
3. Define body temperature (T_b), plus lower \n    and upper critical thermal temperatures.
12
125.0
1

MONITOR
1647
262
1697
307
T_b
[T_b] of turtle 0
1
1
11

MONITOR
474
806
555
851
Activity state
[activity-state] of turtle 0
1
1
11

MONITOR
1648
311
1714
356
in-shade?
in-shade?
1
1
11

MONITOR
615
906
749
951
Time spent resting
restcount
17
1
11

MONITOR
1649
361
1728
406
Zenith angle
zenith
1
1
11

MONITOR
388
806
454
851
NIL
in-food?
17
1
11

MONITOR
388
857
471
902
eaten patches
count patches with [pcolor = 35]
17
1
11

MONITOR
1527
65
1638
110
Diff in reserve level
Maximum-reserve - [reserve-level] of turtle 0
3
1
11

PLOT
1730
259
2103
513
Difference in reserve level over time
NIL
NIL
0.0
5040.0
-10.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "plot Maximum-reserve - [reserve-level] of turtle 0" "plot Maximum-reserve - [reserve-level] of turtle 0"
"pen-1" 1.0 0 -7500403 true "auto-plot-off\nplotxy 0 0\nplotxy 1000000000 0\nauto-plot-on" ""

INPUTBOX
13
1042
125
1102
ctminthresh
120000
1
0
Number

TEXTBOX
13
1020
204
1048
Consecutive hours below min-T_b
11
0.0
1

MONITOR
804
806
960
851
Time spent under min-T_b
[ctmincount] of turtle 0
0
1
11

MONITOR
1529
117
1618
162
Energy gain
[energy-gain] of turtle 0
0
1
11

INPUTBOX
106
666
176
726
Gutthresh
0.75
1
0
Number

MONITOR
1529
165
1635
210
Gutfull
[gutfull] of turtle 0
3
1
11

INPUTBOX
1651
765
1737
825
V_pres
354.87806
1
0
Number

INPUTBOX
1652
828
1737
888
wetstorage
349.04023
1
0
Number

INPUTBOX
1653
957
1736
1017
wetgonad
0.26533
1
0
Number

INPUTBOX
1652
893
1737
953
wetfood
19.86988
1
0
Number

PLOT
1656
516
2017
762
Gutfull
Time
Gut level
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"gutfull" 1.0 0 -16777216 true "" "plot [gutfull] of turtle 0"

INPUTBOX
244
389
309
449
Min-T_b
3.7
1
0
Number

INPUTBOX
314
389
379
449
Max-T_b
51
1
0
Number

MONITOR
1061
804
1151
849
NIL
searchcount
17
1
11

CHOOSER
6
160
98
205
Strategy
Strategy
"Optimising" "Satisficing"
0

PLOT
1741
768
2107
1018
Movement costs
Time
Movement cost (J/cm^3)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Movement cost" 1.0 0 -11221820 true "" ";plot [Movement-cost] of turtle 0\nplot precision sum movelist 10"

MONITOR
974
975
1124
1020
NIL
movelist
2
1
11

INPUTBOX
1165
1034
1692
1094
fh
/Users/malishev/Documents/Melbourne Uni/Programs/Sleepy IBM/Results/
1
0
String

CHOOSER
101
161
198
206
Shade-density
Shade-density
"Random" "Clumped"
1

@#$#@#$#@
> ##Version 6.1.1  Sleepy IBM_v.6.1.1_two strategies (27-4-17)

> 6.1.1_two strategies (5-6-17)
> Added further 'in-food?=FALSE' reporters to searching and resting activity states
> Added in-food? TRUE to handle-food procedure
> Removed extra restcount when Reserve-level = Maximum-reserve

>6.1.1 Sleepy IBM_v.6.1.1_two strategies (27-4-17)
> Added Shade-density chooser to set Random or Clumped shade

> 6.1.1  (6-1-17)
> Set patch 0 0 as Shade

> 6.1.1  (3-1-17)
> Added random and clumped shade patch distribution
> Matched food and shade patch output with input so initial food/shade patch load is divided by 10

> 6.1.1 (26-10-16)
> Added 'fh' variable to set file handle for exporting plots to local hard drive

>> In progress due to "NLCommand("set strategy", NL_strategy)" error in R ('RNL_new trans model_with DEB_1.6.1_olve_movement cost.R')

> 6.1.1 (25-10-16)
> Added movement cost plot and 'movelist' list to calculate cumulative sum of movement costs.

> 6.1.1 (24-10-16)
> Added movement cost to Socialise state (Optimising strategy). Movement cost now added to all movement phases (Searching, Socialising, Shade searching).

> 6.1.1 (19-10-16)
> Added miniscule movement cost (Movement-cost) to avoid turtle exiting green food patches for one time step when feeding.

> 6.1.1. (29-6-16)

> Added movement cost variable to 'to search' and 'to shade-search' procedures (set reserve-level reserve-level - Movement-cost).

> 6.1.1. (16-6-16)

> Changed all instances of Min-T_b and Max-T_b to T_opt_lower and T_opt_upper

> Two movement strategies: 1) move only when hungry or 2) move during all active hours, then feed when hungry. Gut threshold remains at <75% for both strategies.
>> Added 'socialise' procedure to make turtle move when in activity range and when gutfull > gutthresh, i.e. not hungry. Turtle searches for food if gutfull < gutthresh, i.e. hungry

>> Added (gutfull < gutthresh statement) to update-food-levels procedure so turtle doesn't deplete food when passing over patch

>> Added (gutfull < gutthresh) to activity-state = "S" procedure under Optimising strategy

> ##Version 6.1 (30-5-16)

> 6.1 (8-4-16)
> Updated spatial plot area to 750 x 750 patches (1500 x 1500 m)

> 6.1 (2-2-16)
> Converted report-results output to .csv. friendly file

> 6.1 (14-1-16)
> Added gutfull threshold to make turtle feed until gutfull reaches gutthresh level (0.75 or 1), then rest in open sun.

> Added gutfull variable and gutthresh parameter to update turtle gut levels from DEB.R and RNL model

> ##Version 6 (11-5-15)

> Added ctmincounter to tally time spent with Tb under min_T_b_ (critical thermal minimum)

> Fixed spatial plot update commands to correctly plot feeding and resting xy cords--used set-current-plot-pen function in 'to handle-food' procedure, separating food by plot pen color

> Turtle no longer dies--fixes homerange call command and NLGetAgentSet error in RNL model

> Added bounce procedure to make turtle turn a random ~180 degree angle when encountering x and y edges of landscape. This means world margins do not wrap.

> ##Version 5_DEB_no reserve (28-11-14)

> RNL_new trans model_with DEB_1.1.R updates reserve-level, T_b, food intake.

>> Reserve-level and Minimum-reserve should be commented out once gut model in RNL_new trans model_with DEB_1.1.R works.

> Food patches have random floats values to make turtle move to only one food patch

> Includes small and large food patches. Large food incurs twice the handling time (2 ticks).

>> Small food = 3000 J
>> Large food = 6000 J
>> Feeding rate = 3000 J (Low-food-gain) / tick
>> Energy gain = Small food * kap_X (0.8)
>> No min-energy because no food growth. Else, energy of food patch to limit incentive for turtle to revisit food immediately upon leaving food patch (Min-energy) = Small-food-initial

> No food growth

>> Food will grow with water bucket model to update soil moisture profile

> Movement and maintenance cost reduced by ten-fold

>> Maintenance cost should be commented out once DEB model works

> ##Version 5 (2-5-14)

> Basking temperature (T_b_basking) of turtle. When T_b is equal to or greater than T_b_basking and less than T_b_lower, turtle will be in shade but report "in-shade? false" (basking). When greater than T_b_upper, turtle will rest in shade but report "in shade? true.

> Shade level (10 or 90) of shade patches have random float values attached so turtle can choose max-one-of shade patches when confronted with a choice between two shade patches.

> ###Ongoing issues

> Under transient model input, turtle ignores feeding cue if hasn't found shade since start of simulation. Hence, misses feeding period for the day regardless of whether near food. To overcome this: 1) Could always start turtle on shade patch; 2) change make-decision strategy so turtle abandons resting state when within T_opt_range.

> Update reference list with Pamula thesis

#Overview
##Purpose

This soft version of the foraging sub-model focuses on an individual encountering food and shade patches in space and time under one of two contrasting foraging strategies, optimising or satisficing. The individual switches between three different activity states of searching for food, handling food, and resting. This activity generates a global time budget. Foraging performance is measured by the time spent in each state. Thus, we conceive a state-space model. Individuals aim to minimise starvation time. Therefore, the foraging strategy that returns a higher proportion of time spent feeding in the state-space representation is the dominant strategy.

###Questions

What foraging strategy returns a more efficient series of feeding bouts and			 limits starvation over time?

How does time in each activity state influence how the individual is distributed		 in space under the two strategies?

Which strategy performs better on a short hourly compared to a long daily time			 horizon?

###Hypotheses

Satisficing individuals switch less frequently between behavioural states on smaller spatial scales with lower food density.

Satisficing individuals under their risk avoiding strategy experience less starvation periods on long time scales.


## Entities, state variables, and scales

Global state variables of the model:
> Minimum energy of food patches

> Searching state time counter (numeric) [t]

> Feeding state time counter (numeric) [t]

> Resting state time counter (numeric) [t]

> Starvation time counter (numeric; defined by time with maximum vision) [t]

> Transition between activity states time counter (numeric) [t]

There are two entities implemented in the model: the individual and patches.

The individual represent a lizard species (Tiliqua rugosa) and owns the following state-variables:
> Reserve level (numeric value) [J]

> Activity state (factorial; Searching, Feeding, and Resting) []

> Foraging strategy (factorial; Optimising or Satisficing) []

> Search-threshold, below which an individual following the satisficing strategy 			switches from the resting state to the searching state (numeric value) [J]

> Vision radius (numeric; range limited) [m]

Patches are 2*2m in the model space and own the following state variables:
> Patch type (factorial; food patch, shade patch, and bare ground) []

> Energy level (numeric value) [J]


## Process overview and scheduling
Time is scheduled as discrete steps of two minutes.

The model consists of the following sub-modules:

--	Update reserves
--	Decision-making process
--	Searching for food
--	Handling food
--	Searching for shade
--	Resting state
--	Update of habitat variables

At the beginning of each two-minute time step, individuals incur a maintenance cost of 30 J and check their current reserve; if below a critical reserve threshold, the individual will die. Otherwise, the individual makes a decision on the next activity via the decision-making process, which depends on the chosen foraging strategy, current reserve, and current activity state.

The following pseudo code highlights this procedure:

> 	ask individuals
	[
	subtract maintenance cost
	check reserves
		if below a minimum threshold [ die ]
		otherwise [ execute foraging strategy ]
	]

Feeding

If the animal is currently feeding, it continues feeding until reaching a maximum threshold or until the exploitation of the food resource. Both scenarios shift the individual out of a feeding state into a resting state where the individual searches for shade.

Searching

When searching, individuals randomly search for food patches. Food intake and thus reserve level increase stepwise.

Resting

If the individual is currently in the resting state and has reserve above its search-threshold, it stays in this state, otherwise switches to the searching state.

Starvation

Starvation in this model is defined by time not in a feeding state. Starvation periods form a proportion of the global time budget. Only with critical reserves do individuals modify their search strategy to move to the closest available food patch.

Vision

Individual possesses a vision radius, receptive to the nearest food patch and sensitive to reserve. Vision has a minimum radius of spatial units, which increases linearly with depleting reserve of the individual until reaching a maximum level, both defined by state variables. Time spent in the maximum vision range defines the starvation period.

If food patches are absent from the vision range, the individual each time step moves randomly one patch further if under a searching state. If one food patch is in the vision range, the individual aborts a random search strategy and moves to the nearest available food patch.

Patches

Food patches grow by increasing their energy stepwise. Patches check their state variables at each time step to verify their occupancy by an individual in a feeding state, thus reducing its energy-level stepwise until reaching a minimum energy level defined by a global state variable (under feeding state).

Time counter

Transition between activity states increases the activity state counter by 1 tick. Time spent in all states is tallied in 1 tick increments.


### Process

Searching

Individuals move around the environment and lose 217 J per time step in addition to the maintenance cost. Encounter rate with food patches increases energy. Individuals gain 200 and 500 J per small (yellow) and large (green) food patch, respectively.


The following pseudo-code defines the searching procedure:

> 	to execute foraging strategy
		ask individuals
		[
		move randomly
			if food found within vision range
			[move-to food patch]
		]

Handling

Handling time of small and large food patches is two and four ticks, respectively. Conversion of food to usable energy incurs a cost (conversion efficiency of 0.8).

Decision making

Individuals follow one of two foraging strategies.

Satisficing
Individuals follow a demand energy system where food intake is guided toward meeting energy demands and costs only. Individuals satisfy their energy needs by consuming what is currently needed for maintenance and growth. Long patch residence time means an individual requires more time to satisfy energy needs.

Optimising
Individuals follow a supply energy system where food intake decisions are energy maximising depending on total available energy in the environment. Individuals follow rules for leaving food patches based on the Marginal Value Theorem and feed in a patch until the energy intake is lower than the average energy intake of all available patches in the environment. The patch residence time can equal that of satisficing when food patch density is low.

Under both strategies, when reserve falls to a critical value of 5000 J, individuals are at risk of fatal starvation.

Under satisficing, the individual's vision range widens to encompass a greater number of potential food patches. Individuals then abandon random searching and target and move to the closest available food patch.


### Initialisation

At the beginning of the simulation, a fixed number of patches are identified randomly as food patches and attributed small or large food values. Shade patches are also randomly identified. The individual is placed randomly in the landscape with 200,000 J of reserve. Foraging strategy is permanent once model begins. The start activity is set to 'Searching'.


## EXTENDING THE MODEL

See 'Overview, Design concepts, and Details (ODD) protocol for Tiliqua rugosa foraging model' for full model.

## NETLOGO FEATURES

N/A

## RELATED MODELS
For full model see Overview, Design concepts, and Details (ODD) protocol for Tiliqua rugosa foraging model.

## CREDITS AND REFERENCES

Copyright Matt Malishev 2014

Auburn, Z. M. & Bull, C. M (2009) The visual perceptual range of a lizard, Tiliqua rugosa, J. Ethol. 27:75-81
Brown, G. W. (1991) Ecological feeding analysis of south-eastern Australian Scincids  (Reptilia--Lacertilia), Aust. J. Zool. 39:9-29.
Kooijman, S. A. L. M. (2010) Dynamic Energy Budget theory for metabolic organisation. Cambridge University Press.
Norman, H. C., Mayberry, D. E., McKenna, D. J., Pearce, K. L. & Revell D. K. (2008) Old man saltbush in agriculture: feeding value for livestock production systems, 2nd International Salinity Forum: Salinity, water and society--global issues, local action.
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

clock
true
0
Circle -7500403 true true 30 30 240
Polygon -16777216 true false 150 31 128 75 143 75 143 150 158 150 158 75 173 75
Circle -16777216 true false 135 135 30

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

frog top
true
0
Polygon -7500403 true true 146 18 135 30 119 42 105 90 90 150 105 195 135 225 165 225 195 195 210 150 195 90 180 41 165 30 155 18
Polygon -7500403 true true 91 176 67 148 70 121 66 119 61 133 59 111 53 111 52 131 47 115 42 120 46 146 55 187 80 237 106 269 116 268 114 214 131 222
Polygon -7500403 true true 185 62 234 84 223 51 226 48 234 61 235 38 240 38 243 60 252 46 255 49 244 95 188 92
Polygon -7500403 true true 115 62 66 84 77 51 74 48 66 61 65 38 60 38 57 60 48 46 45 49 56 95 112 92
Polygon -7500403 true true 200 186 233 148 230 121 234 119 239 133 241 111 247 111 248 131 253 115 258 120 254 146 245 187 220 237 194 269 184 268 186 214 169 222
Circle -16777216 true false 157 38 18
Circle -16777216 true false 125 38 18

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

lizard
true
0
Polygon -7500403 true true 120 63 116 47 127 20 139 1 150 0 160 1 173 18 183 45 180 65
Polygon -7500403 true true 119 60 179 60 180 90 190 151 180 195 180 225 120 225 120 195 110 150 120 90
Polygon -7500403 true true 167 231 184 232 193 236 195 255 210 255 194 218 185 221 171 220
Polygon -16777216 true false 163 13 171 17 173 25 169 30 166 32
Polygon -16777216 true false 137 13 129 17 127 25 131 30 134 32
Polygon -7500403 true true 120 225 120 270 135 285 165 285 180 270 180 225
Polygon -7500403 true true 167 69 184 68 193 64 195 45 210 45 194 82 185 79 171 80
Polygon -7500403 true true 133 69 116 68 107 64 105 45 90 45 106 82 115 79 129 80
Polygon -7500403 true true 133 231 116 232 107 236 105 255 90 255 106 218 115 221 129 220

moon
false
0
Polygon -7500403 true true 175 7 83 36 25 108 27 186 79 250 134 271 205 274 281 239 207 233 152 216 113 185 104 132 110 77 132 51
Polygon -7500403 true true 175 7 83 36 25 108 27 186 79 250 134 271 205 274 281 239 207 233 152 216 113 185 104 132 110 77 132 51
Polygon -7500403 true true 175 7 83 36 25 108 27 186 79 250 134 271 205 274 281 239 207 233 152 216 113 185 104 132 110 77 132 51

moon zenith
true
15
Circle -7500403 true false 108 3 85
Circle -7500403 false false 42 42 216
Circle -1 true true 133 14 64

orbit 1
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 false true 41 41 218

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

spinner
true
0
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74

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
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
  </experiment>
</experiments>
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
