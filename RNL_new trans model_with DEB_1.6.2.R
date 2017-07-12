# RNL_new trans model_with DEB_1.6.2

# 5-1-17 RNL_new trans model_with DEB_1.6.2
# moved gutfull from 'auxiliary params' to 'update animal and env traits'
# added Random and Clumped shade density input (shadedens) for "Sleepy IBM_v.6.1.1_two strategies_shadedens.nlogo"  
# updated 'Sleepy IBM_v.6.1.1_two strategies.nlogo' NL model so food patch input matches output (Food-patches / 10)
# updated movement strategy input

# 1-12-16 RNL_new trans model_with DEB_1.6.2
# updated zenith angle code

# 30-11-16 RNL_new trans model_with DEB_1.6.1_olve_movement cost
# added new DEB estimations (Mike)
# updated soil moisture input (Mike)
# updated mass input from DEB calcs

#24-10-16 RNL_new trans model_with DEB_1.6.1_olve_movement cost
# added movement cost (loco), spatial movement, spdf, and homerange plot outputs to export results loop
# set movement cost to miniscule amount when not searching to fix feeding behav on green food patches (NLCommand("set Movement-cost", 1e-09) 
# added new direct movement cost (loco)
# changed V_pres to debout[2]

#20-10-16
# updated movement cost loop to reset to 0 in NL when not searching
# added NL_strategy variable to NL setup ... in progress

#28-7-16
# added direct movement cost (loco) estimated from ml 02 g-km (John-Adler 1986) and converted to J 

#16-5-16
# added direct movement cost (NL_move) to DEB loop (if (actstate == "S") {NLCommand("set Movement-cost", NL_move)})
# added direct movement cost initial par values
# updated NL_move var
# uses DEB model that includes direct movement cost (cost of locomotion)  ('DEB_movecost.R')
# changed all instances of Min-T_b and Max-T_b to T_opt_lower and T_opt_upper to relfect changes in Netlogo (v6.1.1_two strategies)
# changed VTMIN and VTMAX to activity range Tb limits

#29-1-16
# created sim count (sc) and function to replace results with most recent results of sim run. use to have access to all previous sim runs. Used for getting mean results from multiple sims.
# added results, spdf, homerange, and NL plots to write results loop 

#14-1-15
# added days to turtle homerange spdf to plot movement paths by day
# added wetmass (V_pres, wetfood, wetgonad, wetstorage) NL plotting function in DEB loop 
# updated DEB loop to run on 2-min time steps
# updated initial debout variables in loop to user friendly values
# added gutfull and gutthresh pars within DEB loop to update feeding behav (decision-making part in NL)

#6-1-15
# defined gutfull and X_food pars prior to sim loop (also fixes error of not recognising gutfull in sim loop)
# added V_pres, wetgonad, wetstorage, and wetfood from debout to results output

#30-12-15 / RNL_new trans model_with DEB_1.6.1_olve
# added plot function to compare gutfill 75% and 100% 
# updated reserve level in loop with 'X_food' and 'actfeed' vars
# updated mass var in NL plot output file name 

#24-12-15 modularised with NicheMapR functions

# 15-6-15
# Added hr<-4*emis*sigma*((Tc+Trad)/2+273)^3 # radiation resistance (Line 270)

#22-5-15
# updated with new DEB model parameters ... still needs Mike to check discrepancies against his params

#11-5-15 (v.1.6)
# Added ctminthresh parameter to keep turtle alive when under VTMIN (12 hours)
# Added plot export function from NL.

#30-4-15
# Updated movement path plot functions to accomodate for new NL spatial plot output in NL model.
 # Movement path plots accept dynamic month input-- sep, nov, dec, etc.

#25-4-15
# Fixed NLGetAgentSet error and homerange plot error (changed 'die' in Soft foraging model (NL))

# 30-3-15
# Added home range polygon plotting function
# Added plotting code for new monthly simulations

#23-3-15
# Added lower and upper activity ranges (NL_T_opt_l, NL_T_opt_u)
# Added procedure for plotting per simulation month

#2-12-14
# new analytical transient model (one lump trans)

# TO DO
# Confirm if new VTMAX of 51 C works for month of November
# Feedcount in NL doesn't match 'NLfoodcount',   ........ under progress
# Need to change q to something other than 0?

# 27-11-14
# WORKING VERSION
# X_food variable changed to X_food<-NLReport("[energy-gain] of turtle 0]")
# DEB loop now runs on one NL hour

# 3-10-14
# Uses simulation part from RNL_new trans model_with DEB.R, but with the following:
#   - NLCommand("set T_b precision", Tb, "2") # Updating Tb
#   - acthr<-NLGetAgentSet("in-food?","turtles", as.data.frame=T) ; acthr<-as.numeric(acthr) # Reports true if turtle is in food. For cum. feeding bouts: acthr<- NLReport("feedcount") (# hours of activity. This would change with input from IBM)
#   - X_food<-NLCommand("ask turtle 0 [set energy-gain Low-food-gain]") # sets energy intake from feeding. (changes with input from IBM)
#   - Reports reserve-level


# 1-10-14
# Now opens NL version 5.1.0
# Removed f==1 from 'Regulates X_food dynamics' loop (Line 1116)

# 16-9-14
 # Tb updated after DEB simulation
 # acthr reports when turtle in food patch
 # Feeding dynamics updates with movement (: 1098)

 #12-9-14
 # NL reserve level updated in NL setup procedure (:634)
 # X_food updates with NL "[handle-food]"" procedure  (:695)

# ---------------------------------------------------------------------------
# ------------------- initial Mac OS and R config ---------------------------
# ---------------------------------------------------------------------------

#if using Mac OSX Mountain Lion + and not already in JQR, download and open JGR 
# after downloading, load JGR
Sys.setenv(NOAWT=1)
library(JGR)
Sys.unsetenv("NOAWT")
JGR()

# JGR onwards
# if already loaded, uninstall RNetlogo and rJava
p<-c("rJava", "RNetlogo")
remove.packages(p)

# install Netlogo and rJava from source if haven't already
install.packages("/Users/malishev/Documents/Melbourne Uni/Programs/R code/RNetlogo/RNetLogo_1.0-2.tar.gz", repos = NULL, type="source")
install.packages("/Users/malishev/Documents/Melbourne Uni/Programs/R code/rJava/rJava_0.9-8.tar.gz", repos = NULL, type="source")

# ------------------- for PC and working Mac OSX ---------------------------
# ------------------- model setup ---------------------------
# install.packages(NicheMapR)
# library(NicheMapR) 
setwd("/Users/malishev/Documents/Melbourne Uni/Programs/Sleepy IBM")
#setwd("C:/Users/mrke/My Dropbox/Student Projects/sleepy IBM")
source('DEB.R')
source('onelump_varenv.R')

#----------- read in microclimate data ---------------
tzone<-paste("Etc/GMT-",10,sep="")
metout<-read.csv('metout_adult.csv')
soil<-read.csv('soil_adult.csv')
shadmet<-read.csv('shadmet_adult.csv')
shadsoil<-read.csv('shadsoil_adult.csv')
micro_sun_all<-cbind(metout[,2:5],metout[,9],soil[,6],metout[,14:16])
colnames(micro_sun_all)<-c('dates','JULDAY','TIME','TALOC','VLOC','TS','ZEN','SOLR','TSKYC')
micro_shd_all<-cbind(shadmet[,2:5],shadmet[,9],shadsoil[,6],shadmet[,14:16])
colnames(micro_shd_all)<-c('dates','JULDAY','TIME','TALOC','VLOC','TS','ZEN','SOLR','TSKYC')

# choose a day(s) to simulate
daystart<-paste('09/09/05',sep="") # yy/mm/dd
dayfin<-paste('10/12/31',sep="") # yy/mm/dd
micro_sun<-subset(micro_sun_all, format(as.POSIXlt(micro_sun_all$dates), "%y/%m/%d")>=daystart & format(as.POSIXlt(micro_sun_all$dates), "%y/%m/%d")<=dayfin)
micro_shd<-subset(micro_shd_all, format(as.POSIXlt(micro_shd_all$dates), "%y/%m/%d")>=daystart & format(as.POSIXlt(micro_shd_all$dates), "%y/%m/%d")<=dayfin)
days<-as.numeric(as.POSIXlt(dayfin)-as.POSIXlt(daystart))

# create time vectors
time<-seq(0,(days+1)*60*24,60) #60 minute intervals from microclimate output
time<-time[-1]
times2<-seq(0,(days+1)*60*24,2) #two minute intervals for prediction
time<-time*60 # minutes to seconds
times2<-times2*60 # minutes to seconds

# apply interpolation functions
velfun<- approxfun(time, micro_sun[,5], rule = 2)
Zenfun<- approxfun(time, micro_sun[,7], rule = 2)
Qsolfun_sun<- approxfun(time, micro_sun[,8], rule = 2)
Tradfun_sun<- approxfun(time, rowMeans(cbind(micro_sun[,6],micro_sun[,9])), rule = 2)
Tairfun_sun<- approxfun(time, micro_sun[,4], rule = 2)
Qsolfun_shd<- approxfun(time, micro_shd[,8]*.1, rule = 2)
Tradfun_shd<- approxfun(time, rowMeans(cbind(micro_shd[,6],micro_shd[,9])), rule = 2)
Tairfun_shd<- approxfun(time, micro_shd[,4], rule = 2)

VTMIN<- 26 # 3.7 #from Bundey field site (2-9-14)
VTMAX<- 35 # 51 #from max(results$Tb)

# ****************************************** read in DEB parameters *******************************

debpars=as.data.frame(read.csv('DEB_pars_Tiliqua_rugosa.csv',header=FALSE))$V1 # read in DEB pars

# set core parameters
z=debpars[8] # zoom factor (cm)
F_m = 13290 # max spec searching rate (l/h.cm^2)
kap_X=debpars[11] # digestion efficiency of food to reserve (-)
v=debpars[13] # energy conductance (cm/h)
kap=debpars[14] # kappa, fraction of mobilised reserve to growth/maintenance (-)
kap_R=debpars[15] # reproduction efficiency (-)
p_M=debpars[16] # specific somatic maintenance (J/cm3)
k_J=debpars[18] # maturity maint rate coefficient (1/h)
E_G=debpars[19] # specific cost for growth (J/cm3)
E_Hb=debpars[20] # maturity at birth (J)
E_Hp=debpars[21] # maturity at puberty (J)
h_a=debpars[22]*10^-1 # Weibull aging acceleration (1/h^2)
s_G=debpars[23] # Gompertz stress coefficient (-)

# set thermal respose curve paramters
T_REF = debpars[1]-273
TA = debpars[2] # Arrhenius temperature (K)
TAL = debpars[5] # low Arrhenius temperature (K)
TAH = debpars[6] # high Arrhenius temperature (K)
TL = debpars[3] # low temp boundary (K)
TH = debpars[4] # hight temp boundary (K)

# set auxiliary parameters
del_M=debpars[9] # shape coefficient (-) 
E_0=debpars[24] # energy of an egg (J)
mh = 1 # survivorship of hatchling in first year
mu_E = 585000 # molar Gibbs energy (chemical potential) of reserve (J/mol)
E_sm=186.03*6

# set initial state
E_pres_init = (debpars[16]*debpars[8]/debpars[14])/(debpars[13]) # initial reserve
E_m <- E_pres_init
E_H_init = debpars[21] + 5

#### change inital size here by multiplying by < 0.85 ####
V_pres_init = (debpars[26] ^ 3) * 0.85 
d_V<-0.3
mass <- V_pres_init + V_pres_init*E_pres_init/mu_E/d_V*23.9

# ***************** end TRANSIENT MODEL SETUP ***************
# ***********************************************************


# initial setup complete, now run the model for a particular 2 min interval


# **************************************************************************************************************
# ***************************************** start NETLOGO SIMULATION  ******************************************

# ****************************************** open NETLOGO *****************************************

install.packages(c("adehabitatHR","rgeos","sp", "maptools", "raster","rworldmap","rgdal","dplyr"))
library(RNetLogo); library(adehabitatHR); library(sp); library(rgeos); library(maptools); library(raster); library(rworldmap); library(rgdal);library(dplyr)
library(rJava) # run rJava?

nl.path<-"/Users/malishev/Documents/Melbourne Uni/Programs/NetLogo 5.3.1/"
#nl.path<-"C:/Program Files/NetLogo 5.3.1/"
#nl.path<-"/Users/malishev/Documents/Melbourne Uni/Programs/NetLogo 5.3.1/app" # for running in El Capitan
#NLStart(nl.path, gui=F, nl.obj=NULL, is3d=FALSE)
NLStart(nl.path)
model.path<-"/Users/malishev/Documents/Melbourne Uni/Programs/Sleepy IBM/Sleepy IBM_v.6.1.1_two strategies.nlogo"
#model.path<-"C:/Users/mrke/My Dropbox/Student Projects/sleepy IBM/Sleepy IBM_v.6.1.1_two strategies.nlogo"
NLLoadModel(model.path)

# set results path
results.path<-"/Users/malishev/Documents/Melbourne Uni/Programs/Sleepy IBM/Results/"
#results.path<-"C:/Users/mrke/My Dropbox/Student Projects/sleepy IBM/Results/"

# ****************************************** setup NETLOGO MODEL **********************************

# 1. update animal and env traits
month<-"sep"
density<-"high"
NL_days<-5       # No. of days simulated

if(density=="high"){
	NL_shade<-100000L       # Shade patches
	NL_food<-100000L         # Food patches
	}else{ 
	NL_shade<-1000L 	# Shade patches
	NL_food<-1000L	# Food patches
}
NL_gutthresh<-0.75
gutfull<-0.8

# 2. update initial conditions for DEB model 
Es_pres_init<-(E_sm*gutfull)*V_pres_init
acthr<-1
Tb_init<-20
step = 1/24
debout<-DEB(step = step, z = z, del_M = del_M, F_m = F_m * 
    step, kap_X = kap_X, v = v * step, kap = kap, p_M = p_M * 
    step, E_G = E_G, kap_R = kap_R, k_J = k_J * step, E_Hb = E_Hb, 
    E_Hj = E_Hb, E_Hp = E_Hp, h_a = h_a/(step^2), s_G = s_G, 
    T_REF = T_REF, TA = TA, TAL = TAL, TAH = TAH, TL = TL, 
    TH = TH, E_0 = E_0, E_pres=E_pres_init, V_pres=V_pres_init, E_H_pres=E_H_init, acthr = acthr, breeding = 1, Es_pres = Es_pres_init, E_sm = E_sm)


# 3. calc direct movement cost
# ------- New loco cost 16-10-16 -------
V_pres<-debout[2]
step<-1/24 #hourly
#step<-2/1440 #2min

p_M2<-p_M*step #J/h
p_M2<-p_M2*V_pres # loco cost * structure
names(p_M2)<-NULL # remove V_pres name attribute from p_M

# movement cost for time period
VO2<-0.45 # O2/g/h JohnAdler etal 1986

# multiple p_M by structure = movement cost (diff between p_M with loco cost and structure for movement period)
# p_M with loco cost 
loco<-VO2*mass*20.1 # convert ml O2 to J = J/h 
loco<-loco+p_M2 # add to p_M = J/h
loco<-loco/30/V_pres ; loco #J/cm3/2min

Es_pres_init<-(E_sm*gutfull)*V_pres_init
X_food<-3000
V_pres<-debout[2]
wetgonad<-debout[19]
wetstorage<-debout[20]
wetfood<-debout[21]
ctminthresh<-120000
Tairfun<-Tairfun_shd
Tc_init<-Tairfun(1)+0.1 # Initial core temperature

NL_T_b<-Tc_init       # Initial T_b
NL_T_b_min<-VTMIN         # Min foraging T_b
NL_T_b_max<-VTMAX        # Max foraging T_b
NL_ctminthresh<-ctminthresh # No. of consecutive hours below CTmin that leads to death
NL_reserve<-E_m        # Initial reserve density
NL_max_reserve<-E_m    # Maximum reserve level
NL_maint<-round(p_M, 3)               # Maintenance cost
NL_move<-round(loco, 3) 		      # Movement cost
NL_zen<-Zenfun(1*60*60)     # Zenith angle

strategy<-function(strategy){ # set movement strategy 
  if (strategy == "O"){
    NLCommand("set strategy \"Optimising\" ") 
    }else{
    NLCommand("set strategy \"Satisficing\" ") 
    }
  }
strategy("O") # "S"

shadedens<-function(shadedens){ # set movement strategy 
  if (shadedens == "Random"){
    NLCommand("set Shade-density \"Random\" ") 
    }else{
    NLCommand("set Shade-density \"Clumped\" ") 
    }
  }
shadedens("Clumped") # "Clumped"

sc<-1 # sim count for automating writing of each sim results to file (set before NL loop)
for (i in 1:sc){ # start sc sim loop

NLCommand("set Shade-patches",NL_shade,"set Food-patches",NL_food,"set No.-of-days",NL_days,"set T_b precision",
NL_T_b, "2","set T_opt_lower precision", NL_T_b_min, "2","set T_opt_upper precision", NL_T_b_max, "2",
"set reserve-level", NL_reserve, "set Maximum-reserve", NL_max_reserve, "set Maintenance-cost", NL_maint,
"set Movement-cost precision", NL_move, "3", "set zenith", NL_zen, "set ctminthresh", NL_ctminthresh, 
"set gutthresh", NL_gutthresh, 'set gutfull', gutfull, 'set V_pres precision', V_pres, "5", 'set wetstorage precision', wetstorage, "5", 
'set wetfood precision', wetfood, "5", 'set wetgonad precision', wetgonad, "5","setup")

#NLCommand("inspect turtle 0")

NL_ticks<-NL_days / (2 / 60 / 24) # No. of NL ticks (measurement of days)
NL_T_opt_l<-NLReport("[T_opt_lower] of turtle 0")
NL_T_opt_u<-NLReport("[T_opt_upper] of turtle 0")

# data frame setup for homerange polygon
turtles<-data.frame() # make an empty data frame
NLReport("[X] of turtle 0"); NLReport("[Y] of turtle 0")
who<-NLReport("[who] of turtle 0")

# **********************************************************
# ******************** start NETLOGO SIMULATION  ***********
debcall<-0 # check for first call to DEB
stepcount<-0 # DEB model step count

for (i in 1:NL_ticks){
stepcount<-stepcount+1
NLDoCommand(1, "go")

######### Reporting presence of shade
#if (NLReport("any? turtles")){
shade<-NLGetAgentSet("in-shade?","turtles", as.data.frame=T); shade<-as.numeric(shade) # returns an agentset of whether turtle is currently on shade patch
#food<-NLGetAgentSet("in-food?","turtles", as.data.frame=T) ; food<-as.numeric(food)
#}

# choose sun or shade
tick<-i
times3<-c(times2[tick],times2[tick+1])

if(shade==0){
  Qsolfun<-Qsolfun_sun
  Tradfun<-Tradfun_sun
  Tairfun<-Tairfun_sun
}else{
  Qsolfun<-Qsolfun_shd
  Tradfun<-Tradfun_shd
  Tairfun<-Tairfun_shd
}
if(i==1){
Tc_init<-Tairfun(1)+0.1 #initial core temperature
#Zenf<-Zenf(1*60*60)  # initial zenith angle at 1 a.m (?)
}

# ----------------------------------- 2-12-14 new one_lump_trans params
Qsol<-Qsolfun(mean(times3)); Qsol
vel<-velfun(mean(times3)) ;vel
Tair<-Tairfun(mean(times3));Tair
Trad<-Tradfun(mean(times3)); Trad
Zen<-Zenfun(mean(times3)); Zen

# calc Tb params at 2 mins interval
Tbs<-onelump_varenv(t=120,time=times3[2],Tc_init=Tc_init,thresh = 30, AMASS = mass, lometry = 3, Tairf=Tairfun,Tradf=Tradfun,velf=velfun,Qsolf=Qsolfun,Zenf=Zenfun)
Tb<-Tbs$Tc
rate<-Tbs$dTc
Tc_init<-Tb

NLCommand("set T_b precision", Tb, "2") # Updating Tb
#NLCommand("set zenith", Zenfun(i*60*60)) # Updating zenith
NLCommand("set zenith", Zenfun(times3[2])) # Updating zenith

# time spent below VTMIN
ctminhours<-NLReport("[ctmincount] of turtle 0") * 2/60 # ticks to hours
if (ctminhours == NL_ctminthresh) {NLCommand("ask turtle 0 [stop]")}

# ******************** start DEB SIMULATION  ***************

if(stepcount==1) { # run DEB loop every time step (2 mins)
stepcount<-0

# report activity state
actstate<-NLReport("[activity-state] of turtle 0")
 # Reports true if turtle is in food 
actfeed<-NLGetAgentSet("in-food?","turtles", as.data.frame=T); actfeed<-as.numeric(actfeed)
 
n<-1 # time steps
step<-2/1440 # step size (2 mins). For hourly: 1/24
# update direct movement cost
if(actstate == "S"){
	NLCommand("set Movement-cost", NL_move)
	}else{
		NLCommand("set Movement-cost", 1e-09)
		} 
# if within activity range, it's daytime, and gut below threshold 
if(Tbs$Tc>=VTMIN & Tbs$Tc<=VTMAX & Zen!=90 & gutfull<=NL_gutthresh){ 
  acthr=1 # activity state = 1 
if(actfeed==1){ # if in food patch
	X_food<-NLReport("[energy-gain] of turtle 0") # report joules intake
	}
	}else{
		X_food = 0 
		acthr=0
		}

# calculate DEB output 
if(debcall==0){
	# initialise DEB
	debout<-matrix(data = 0, nrow = n, ncol = 26)
	deb.names<-c("E_pres","V_pres","E_H_pres","q_pres","hs_pres","surviv_pres","Es_pres","cumrepro","cumbatch","p_B_past","O2FLUX","CO2FLUX","MLO2","GH2OMET","DEBQMET","DRYFOOD","FAECES","NWASTE","wetgonad","wetstorage","wetfood","wetmass","gutfreemass","gutfull","fecundity","clutches")
	colnames(debout)<-deb.names
	# initial conditions
	debout<-DEB(E_pres=E_pres_init, V_pres=V_pres_init, E_H_pres=E_H_init, acthr = acthr, Tb = Tb_init, breeding = 1, Es_pres = Es_pres_init, E_sm = E_sm, step = step, z, del_M = del_M, F_m = F_m * 
    step, kap_X = kap_X, v = v * step, kap = kap, p_M = p_M * 
    step, E_G = E_G, kap_R = kap_R, k_J = k_J * step, E_Hb = E_Hb, 
    E_Hj = E_Hb, E_Hp = E_Hp, h_a = h_a/(step^2), s_G = s_G, 
    T_REF = T_REF, TA = TA, TAL = TAL, TAH = TAH, TL = TL, 
    TH = TH, E_0 = E_0)
	debcall<-1
	}else{
		debout<-DEB(step = step, z = z, del_M = del_M, F_m = F_m * 
    step, kap_X = kap_X, v = v * step, kap = kap, p_M = p_M * 
    step, E_G = E_G, kap_R = kap_R, k_J = k_J * step, E_Hb = E_Hb, 
    E_Hj = E_Hb, E_Hp = E_Hp, h_a = h_a/(step^2), s_G = s_G, 
    T_REF = T_REF, TA = TA, TAL = TAL, TAH = TAH, TL = TL, 
    TH = TH, E_0 = E_0, 
		  X=X_food,acthr = acthr, Tb = Tbs$Tc, breeding = 1, E_sm = E_sm, E_pres=debout[1],V_pres=debout[2],E_H_pres=debout[3],q_pres=debout[4],hs_pres=debout[5],surviv_pres=debout[6],Es_pres=debout[7],cumrepro=debout[8],cumbatch=debout[9],p_B_past=debout[10])
		}
mass<-debout[22]
gutfull<-debout[24]
NL_reserve<-debout[1]
V_pres<-debout[2]
wetgonad<-debout[19]
wetstorage<-debout[20]
wetfood<-debout[21] 

#update NL wetmass properties 
NLCommand("set V_pres precision", V_pres, "5")
NLDoCommand("plot xcor ycor")
NLCommand("set wetgonad precision", wetgonad, "5")
NLDoCommand("plot xcor ycor")
NLCommand("set wetstorage precision", wetstorage, "5")
NLDoCommand("plot xcor ycor")
NLCommand("set wetfood precision", wetfood, "5")
NLDoCommand("plot xcor ycor") 
 

} #--- end DEB loop

NLCommand("set reserve-level", NL_reserve) # update reserve
NLCommand("set gutfull", debout[24])# update gut level

# ******************** end DEB SIMULATION ******************

# generate results, with V_pres, wetgonad, wetstorage, and wetfood from debout
if(i==1){
	results<-cbind(tick,Tb,rate,shade,V_pres,wetgonad,wetstorage,wetfood,NL_reserve) 
	}else{
		results<-rbind(results,c(tick,Tb,rate,shade,V_pres,wetgonad,wetstorage,wetfood,NL_reserve))
		}
results<-as.data.frame(results)

# generate data frames for homerange polygon
if (tick == NL_ticks - 1){
	X<-NLReport("[X] of turtle 0"); head(X)
	Y<-NLReport("[Y] of turtle 0"); head(Y)
	turtles<-data.frame(X,Y)
	who1<-rep(who,NL_ticks); who # who1<-rep(who,NL_ticks - 1); who 
	turtledays<-rep(1:NL_days,length.out=NL_ticks,each=720) 
	turtle<-data.frame(ID = who1,days=turtledays)
	turtles<-cbind(turtles,turtle)
	}

} # *************** end NL loop **************************

# get hr data
spdf<-SpatialPointsDataFrame(turtles[1:2], turtles[3]) # creates a spatial points data frame (adehabitatHR package)
homerange<-mcp(spdf,percent=95)

# writing new results
if (exists("results")){  #if results exist
	sc<-sc-1 
	nam <- paste("results", sc, sep = "") # generate new name with added sc count
	rass<-assign(nam,results) #assign new name to results. call 'results1, results2 ... resultsN'
	namh <- paste("turtles", sc, sep = "")  #generate new name with added sc count
	rassh<-assign(namh,turtles) #assign new name to results. call 'results1, results2 ... resultsN'
	nams <- paste("spdf", sc, sep = "") 
	rasss<-assign(nams,spdf) 
	namhr <- paste("homerange", sc, sep = "")  
	rasshr<-assign(namhr,homerange) 

	# write each result for each sim to file dir getwd()
		#CAMEL comp dir
	#"C:/NicheMapR_Working/projects/sleepy_ibm_transient/"
	
	#using NL file handle variable to export files (fh = "/Users/malishev/Documents/Melbourne Uni/Programs/Sleepy IBM/Results/")
	#no error, but no file in dir
	#NLCommand(paste("export-plot \"Movement costs\" \"fh",lfh,".csv\"",sep=""))
	# no error and exports to dir when NL 'fh' variable has "name.csv" 
	# NLCommand('export-plot \"Movement costs\"','fh') 
	# working R version of 'fh' 
#	paste("export-plot \"Body temperature (T_b)\"",fh,tfh,".csv",sep="")

	fh<-results.path; fh
	for (i in rass){
		# export all results
		write.table(results,file=paste(fh,nam,".R",sep=""))
		}
	for (i in rassh){
		# export turtle location data
		write.table(turtles,file=paste(fh,namh,".R",sep=""))
		}
#	for (i in rasss){
		# export spdf data
#		write.table(spdf,file=paste(fh,nams,".R",sep=""))  
#		}
#	for (i in rasshr){
		# export hr data
#		write.table(homerange,file=paste(fh,namhr,".R",sep=""))  
#		}
		#export NL plots
		month<-"sep"
		#spatial plot
		sfh<-paste(month,NL_days,round(mass,0),NL_shade,as.integer(NL_food),"_",sc,"_move","",sep="");sfh
		NLCommand(paste("export-plot \"Spatial coordinates of transition between activity states\" \"",results.path,sfh,".csv\"",sep=""))
		#temp plot 
		tfh<-paste(month,NL_days,round(mass,0),NL_shade,as.integer(NL_food),"_",sc,"_temp",sep="")
		NLCommand(paste("export-plot \"Body temperature (T_b)\" \"",results.path,tfh,".csv\"",sep=""))
		#activity budget
		afh<-paste(month,NL_days,round(mass,0),NL_shade,as.integer(NL_food),"_",sc,"_act","",sep="");afh
		NLCommand(paste("export-plot \"Global time budget\" \"",results.path,afh,".csv\"",sep=""))
		#text output
		xfh<-paste(month,NL_days,round(mass,0),NL_shade,as.integer(NL_food),"_",sc,"_txt",sep="");xfh
		NLCommand(paste("export-output \"",results.path,xfh,".csv\"",sep=""))
		#gut level
		gfh<-paste(month,NL_days,round(mass,0),NL_shade,as.integer(NL_food),"_",sc,"_gut","",sep="");gfh
		NLCommand(paste("export-plot \"Gutfull\" \"",results.path,gfh,".csv\"",sep=""))
		#wet mass 
		mfh<-paste(month,NL_days,round(mass,0),NL_shade,as.integer(NL_food),"_",sc,"_wetmass","",sep="");mfh
		NLCommand(paste("export-plot \"Total wetmass plot\" \"",results.path,mfh,".csv\"",sep=""))
		#movement cost (loco) 
		lfh<-paste(month,NL_days,round(mass,0),NL_shade,as.integer(NL_food),"_",sc,"_loco","",sep="");lfh
		NLCommand(paste("export-plot \"Movement costs\" \"",results.path,lfh,".csv\"",sep=""))
	}
} # ********************** end sc sim loop **********************


#*********************** end NETLOGO SIMULATION ****************************
#***************************************************************************

results<-as.data.frame(results);results7<-as.data.frame(results7)   

# plotting debout results
plot(results$V_pres,type='h',ylim=c(0,max(results$V_pres)))
with(results,points(wetstorage,type='h',col='light blue')) 
with(results,points(wetfood,type='h',col='red'))  
with(results,points(wetgonad,type='h',col='green'))
with(results,points(NL_reserve,type='h',col='orange'))  
plot(results$NL_reserve,type='h',col='orange')

plot(results7$V_pres,type='l',ylim=c(0,max(results7$V_pres)))
with(results7,points(wetstorage,type='l',col='light blue')) 
with(results7,points(wetfood,type='l',col='red')) 
with(results7,points(wetgonad,type='h',col='green'))
with(results7,points(NL_reserve,type='h',col='red'))  
plot(results7$NL_reserve,type='l',col='orange')

# compare Tb for 75% and 100% gutfull
plot(results$Tb,col='black',las=1,type='l',
xaxt='n', 
xlab="Days",
ylab='Tb',
main = paste('Tb with 75% (red) and 100% (black) gutfull par from ',daystart,' for ',NL_days,' days',sep=''),
)
with(results7,points(Tb,col='red', type='l'))
axis(1,at=c(0,(length(results$Tb)/2),length(results$Tb)),labels=c(0,NL_days/2,NL_days))

# ---------------------- home range plots 
spdf<-SpatialPointsDataFrame(turtles[1:2], turtles[3]) # creates a spatial points data frame (adehabitatHR package)
homerange<-mcp(spdf,percent=100)

# change this with each sim
hr7<-homerange
hrpath7<-spdf

# original code. NB: using min/maxpcors doesn't work for exporting plot to pdf or jpeg
minpxcor<-NLReport("min-pxcor");maxpxcor<-NLReport("max-pxcor")
minpycor<-NLReport("min-pycor");maxpycor<-NLReport("max-pycor")
# plot 75% and 100% gutfull HRs
colvec = adjustcolor(c("black"), alpha = 0.5)
plot(hr7,lty=1,bty="o",pch=21,col=colvec, xlim=c(minpxcor,maxpxcor),ylim=c(minpycor,maxpycor),axes=F)
plot(hrpath7,pch=3,col=turtles$days,add=T)

colvec = adjustcolor(c("red"), alpha = 0.5)
plot(hr7,lty=1,bty="o",col=colvec,add=T)
plot(hrpath7,pch=3,col=turtles$days,add=T) 

# use if axes = F
realaxis<-c(minpxcor*2,minpxcor,0,maxpxcor,maxpxcor*2)
axis(1,at=c(minpxcor,minpxcor/2,0,maxpxcor/2,maxpxcor),labels=realaxis)
axis(2,at=c(minpycor,minpycor/2,0,maxpycor/2,maxpycor),labels=realaxis)
text(maxpxcor/2,minpycor/2,paste("100% area = \n",hr$area,sep=""))# hr
text(minpxcor/2,minpycor,paste("75% area = \n",hr7$area,sep=""))# hr7
par(new=T); plot(0, type="n",xlab="X",ylab="Y", 
main=paste('Homerange for 75% gut threshold for ',NL_days,' days from ',daystart,sep=''),
main=paste('Red=75% gutfull , black=100% gutfull for ',NL_days,' days from ',daystart,sep=''),
axes=F)
box(which="plot")

# summary stats for homerange sizes
summary(turtles)
max(turtles$X) - min(turtles$X) # width of HR
max(turtles$Y) - min(turtles$Y) # height of HR

# diff in HR
diffhr<-hr-hr7; diffhr
plot(diffhr,lty=1,bty='o',col=colvec_h)


# ------------------------ export plots from NL --------------------------

month<-"sep"

#dir = /Applications/Programs/NetLogo 5.0.5/Soft foraging model/Simulations

#spatial plot
sfh<-paste(month,NL_days,round(mass,0),NL_shade,NL_food,"_move","",sep="");sfh
#NLCommand("export-plot \"Spatial coordinates of transition between activity states\" \"Simulations/spatialplot.csv\"")
NLCommand(paste("export-plot \"Spatial coordinates of transition between activity states\" \"Simulations/",sfh,".csv\"",sep=""))
# home range
hfh<-paste(month,NL_days,round(mass,0),NL_shade,NL_food,"_homerange","",sep="");hfh
# reserve plot
rfh<-paste(month,NL_days,round(mass,0),NL_shade,NL_food,"_reserve","",sep="");rfh
#NLCommand("export-plot \"Reserve level and starvation reserve over time\" \"Simulations/reserveplot.csv\"")
NLCommand(paste("export-plot \"Reserve level and starvation reserve over time\" \"Simulations/",rfh,".csv\"",sep=""))
#temp plot
tfh<-paste(month,NL_days,round(mass,0),NL_shade,NL_food,"_temp",sep="");tfh
#NLCommand("export-plot \"Body temperature (T_b)\" \"Simulations/tempplot.csv\"")
NLCommand(paste("export-plot \"Body temperature (T_b)\" \"Simulations/",tfh,".csv\"",sep=""))
# activity budget
afh<-paste(month,NL_days,round(mass,0),NL_shade,NL_food,"_act","",sep="");afh
#NLCommand("export-plot \"Global time budget\" \"Simulations/activitybudget.csv\"")
NLCommand(paste("export-plot \"Global time budget\" \"Simulations/",afh,".csv\"",sep=""))
# world view
NLCommand("export-view \"Simulations/worldview.png\"")
# text output
xfh<-paste(month,NL_days,round(mass,0),NL_shade,NL_food,"_txt",sep="");xfh
NLCommand(paste("export-output \"Simulations/",xfh,".csv\"",sep=""))
# gut level
gfh<-paste(month,NL_days,round(mass,0),NL_shade,NL_food,"_gut","",sep="");gfh
#NLCommand("export-plot \"Global time budget\" \"Simulations/activitybudget.csv\"")
NLCommand(paste("export-plot \"Gutfull\" \"Simulations/",gfh,".csv\"",sep=""))




#-----------------------------------------------------------
#------------------------ plot NETLOGO RESULTS -------------
#-----------------------------------------------------------

###
### add export function that saves plot as e.g. "sep15"
###

#fh<-paste(daystart,NL_days,mass,NL_shade,NL_food,sep="")
ttl<-paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")
pdf(paste("/Applications/Programs/NetLogo 5.0.5/NL_transient_outputs/",fh,".pdf",sep=""),width=15,height=15,paper="a4r",title=ttl)

par(mfrow=c(1,1)) # new plot window with x rows and y columns, fills by rows
par(mar=c(5,6,5,5))

#------------------ regular results plot ------------------------

#NL_shade<-NLReport("Shade-patches"); NL_food<-NLReport("Food-patches")
results<-as.data.frame(results)
ticktime<-results$tick * 2 / 60 / 24 # convert to real days

# Plot with title
# with(results,plot(Tb~ticktime,type='l',las=1,xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)")),main=paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")))
with(results,plot(Tb~ticktime,type='l',las=1,xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)"))))
shade.results<-results[results$shade %in% 1,] ; head(shade.results)
sticktime<-shade.results$tick * 2 / 60 / 24 # convert to real days
shade.results_Tb<-results[results$shade %in% 1,'Tb'] ; head(shade.results_Tb)
#with(results,points(shade.results$Tb~shade.results$tick, type='p', col="blue"))
with(results,points(shade.results$Tb~sticktime, type='p', col="blue"))
#with(results,points(shade*20~tick,type='p',col="red"))
abline(h = c(NL_T_opt_l,NL_T_opt_u), col = "red", lty = 3)
text(0,28, "Activity range", col = "red", adj = c(.3, 1))

# dev.off()  # use only with jpeg function above

hist(shade.results$Tb, main="Proportion of Tb when in shade", xlab="Tb (C) when in shade")
plot(shade.results$tick,shade.results$Tb, col="blue")

# ------------------ Tb plot per month ------------------------
	
if (exists("results")){
  newones<-results
  }
# change this to reflect new data period and save as dataframe
dec15<-newones

ticktime<-newones$tick * 2 / 60 / 24 # convert to real days
# define shade data frame
shade.newones<-newones[newones$shade %in% 1,]
shade.newones_Tb<-newones[newones$shade %in% 1,'Tb'] ; head(shade.newones_Tb)
sticktime<-shade.newones$tick * 2 / 60 / 24 # convert to real days

#sep15: lty=3
#nov1: lty=2
#dec15: lty=1

month<-"dec15"
par(pty="m")
fh<-paste(month,NL_days,mass,NL_shade,NL_food,"_2",sep="")
ttl<-paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")
pdf(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Tb plot/",fh,".pdf",sep=""),width=15,height=15,paper="a4r",title=ttl)
#plot.new()

#par(new=T)

# make data points transparent
colvec = adjustcolor(c("red"), alpha = 0.5)
col=colvec[sep15$Tb]

# Plot with title
# with(results,plot(Tb~ticktime,type='l',las=1,xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)")),main=paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")))
with(newones,plot(Tb~ticktime,type='l',las=1,lwd=1,lty=1,col=colvec,xlim=c(0,NL_days),ylim=c(0,45),xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)"))))
#with(results,points(shade.results$Tb~shade.results$tick, type='p', col="blue"))
with(newones,points(shade.newones$Tb~sticktime, type='p', col=colvec))
#with(results,points(shade*20~tick,type='p',col="red"))
abline(h = c(NL_T_opt_l,NL_T_opt_u), col = "red", lty = 3)
text(0,28, "Activity range", col = "red", adj = c(.3, 1))

dev.off()



# ------------------ simultaneous simulation plots --------------------

par(mfrow=c(1,1),mar=c(5,6,5,5),pty="m")
month<-"all"
fh<-paste(month,NL_days,mass,NL_shade,NL_food,"",sep="");fh
ttl<-paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")
pdf(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Tb plot/",fh,".pdf",sep=""),width=15,height=15,paper="a4r",title=ttl)
#plot.new()

# sep15

# make data points transparent
colvec = adjustcolor(c("black"), alpha = 0.3)
#col=colvec[sep15$Tb]

ticktime<-sep15$tick * (2 / 60 / 24) # convert to real days
sticktime<-shade.sep15$tick * 2 / 60 / 24 # convert to real days
with(sep15,plot(Tb~ticktime,type='l',las=1,lwd=2,lty=1,,col=colvec,xlim=c(0,max(ticktime)),ylim=c(0,45),xlab="",ylab="",axes=F))
shade.sep15<-sep15[sep15$shade %in% 1,] ; head(shade.sep15)
shade.sep15_Tb<-sep15[sep15$shade %in% 1,'Tb'] ; head(shade.sep15_Tb)
#with(results,points(shade.results$Tb~shade.results$tick, type='p', col="blue"))
with(sep15,points(shade.sep15$Tb~sticktime, type='p', col=colvec))


#nov1

colvec = adjustcolor(c("blue"), alpha = 0.3)

ticktime<-nov1$tick * (2 / 60 / 24) # convert to real days
sticktime<-shade.nov1$tick * 2 / 60 / 24 # convert to real days
par(new=T)
with(nov1,plot(Tb~ticktime,type='l',las=1,lwd=2,lty=1,col=colvec,xlim=c(0,max(ticktime)),ylim=c(0,45),xlab="",ylab="",axes=F))
shade.nov1<-nov1[nov1$shade %in% 1,] ; head(shade.nov1)
shade.nov1_Tb<-nov1[nov1$shade %in% 1,'Tb'] ; head(shade.nov1_Tb)
#with(results,points(shade.results$Tb~shade.results$tick, type='p', col="blue"))
with(nov1,points(shade.nov1$Tb~sticktime, type='p', col=colvec))

#dec15

colvec = adjustcolor(c("red"), alpha = 0.3)

ticktime<-dec15$tick * (2 / 60 / 24) # convert to real days
sticktime<-shade.dec15$tick * 2 / 60 / 24 # convert to real days
par(new=T)
with(dec15,plot(Tb~ticktime,type='l',las=1,lwd=2,lty=1,col=colvec,xlim=c(0,max(ticktime)),ylim=c(0,45),xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)"))))
shade.dec15<-dec15[dec15$shade %in% 1,] ; head(shade.dec15)
shade.dec15_Tb<-nov1[dec15$shade %in% 1,'Tb'] ; head(shade.dec15_Tb)
#with(results,points(shade.results$Tb~shade.results$tick, type='p', col="blue"))
with(dec15,points(shade.dec15$Tb~sticktime, type='p', col=colvec))
abline(h = c(NL_T_opt_l,NL_T_opt_u), col = "red", lty = 3)
text(0,30, "Activity range", col = "red", adj = c(.3, 1))



 dev.off()  # use only with jpeg function above

hist(shade.results$Tb, main="Proportion of Tb when in shade", xlab="Tb (C) when in shade")
plot(shade.results$tick,shade.results$Tb, col="blue")




# ----------- home range plot ------------------


# get homerange ------------------
#X<-NLReport("[X] of turtle 0"); head(X)
#Y<-NLReport("[Y] of turtle 0"); head(Y)
#  turtles<-data.frame(X,Y)
#  who1<-rep(who,NL_ticks); who #
#who1<-rep(who,NL_ticks); who
#  turtle<-data.frame(ID = who1)
#  turtles<-cbind(turtles,turtle)
#
#
 
# need to make new variable for new spdf (movement paths)  ........ under progress
spdf<-SpatialPointsDataFrame(turtles[1:2], turtles[3]) # creates a spatial points data frame (adehabitatHR package)
homerange<-mcp(spdf,percent=100)

# draw-homerange ------------------
#calculate homerange points
temp <- slot(homerange,'polygons')[[which(slot(homerange,'data')$id == who)]]@Polygons[[1]]@coords
tempX<-temp[,1]
tempY<- temp[,2]
#tempXY<-cbind(tempX,tempY); tempXY<-as.list(tempXY)
tempXY<-NLCommand("set tempXY (map [list ?1 ?2]",tempX,tempY, ")" )
# Setting as.list makes no difference
 #as.list(tempXY)

# The below command doesn't work yet, so the model calls the NL 'draw-homerange' procedure instead
#NLCommand("set tempX", tempX, "set tempY", tempY, "set tempXY", tempXY)
NLCommand("draw-homerange")

# hatch a turtle to draw the homerange boundary points
   NLCommand("ask turtle 0 [hatch-homeranges 1", "hide-turtle","set color red]")
# draw the homerange
  NLCommand("foreach tempXY [ask homeranges", "[move-to patch (item 0 ?) (item 1 ?)", "pd]]")
# close the homerange polygon
  NLCommand("ask homeranges [let lastpoint first tempXY","move-to patch (item 0 lastpoint) (item 1 lastpoint)","]")

# to save-homerange ---------------

# change this with each sim
sep15_homerange<-homerange

month<-"all"
par(new=T)
par(pty="s")
#save the homerange polygon into a pdf
fh<-paste(month,NL_days,mass,NL_shade,NL_food,"_homerange","",sep="");fh
ttl<-paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")
#pdf(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Home range polygon/",fh,".pdf",sep=""),width=15,height=15,paper="a4r",title=ttl)
pdf(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Home range polygon/",fh,".pdf",sep=""))
jpeg(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Home range polygon/",fh,".jpeg",sep=""))

# plot polygon
colvec_h = adjustcolor(c("black"), alpha = 0.5)
plot(sep15_homerange,lty=1,bty="o",col=colvec_h,lwd=2,xlim=c(-25,25),ylim=c(-25,25),axes=F)
# plot animal tracks in polygon. NB: col = white. ........ under progress
plot(spdf,col=as.data.frame(spdf)[,1],pch=4,add=T)

# adding 2nd homerange polygon
colvec_h = adjustcolor(c("blue"), alpha = 0.2)
plot(nov1_homerange,lty=1,bty="o",col=colvec_h,lwd=2,xlim=c(-25,25),ylim=c(-25,25),axes=F,add=T)
# plot animal tracks in polygon. NB: col = white......... under progress
plot(spdf,col=as.data.frame(spdf)[,1],pch=4,add=T)

# adding 3rd homerange polygon
colvec_h = adjustcolor(c("red"), alpha = 0.2)
plot(dec15_homerange,lty=1,bty="o",col=colvec_h,lwd=2,xlim=c(-25,25),ylim=c(-25,25),axes=F,add=T)
# plot animal tracks in polygon. NB: col = white......... under progress
plot(spdf,col=as.data.frame(spdf)[,1],pch=4,add=T)
text(-16,5,labels="A",cex=1.5);text(0,5,labels="B",cex=1.5); text(14,5,labels="C",cex=1.5)

# use if axes = F
realaxis<-c("-50","-25","0","25","50")
axis(1,at=c(-25,-12.5,0,12.5,25),labels=realaxis)
axis(2,at=c(-25,-12.5,0,12.5,25),labels=realaxis)
par(new=T); plot(0, type="n",xlab="X",ylab="Y",axes=F)

box(which="plot")

dev.off()

#save a plot of the homerange area level into a pdf
pdf(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Home range polygon/",month,"_homearea",".pdf",sep=""))
plot(mcp.area(spdf,unout='m2'),colpol="blue",main=paste("Homerange polygon for ",NL_days," days with ",NL_shade," shade and ",NL_food," food patches"))
dev.off()

# original code. NB: using min/maxpcors doesn't work for exporting plot to pdf or jpeg
minpxcor<-NLReport("min-pxcor");maxpxcor<-NLReport("max-pxcor")
minpycor<-NLReport("min-pycor");maxpycor<-NLReport("max-pycor")
plot(nov1_homerange,lty=3,lwd=2,xlab="X", ylab="Y", xlim=c(minpxcor,maxpxcor), ylim=c(minpycor,maxpycor), axes=T)
par(new=T); plot(0, type="n",xlab="X coordinates",ylab="Y coordinates",axes=F)




#-----------------------------------------------------------
#------------------------ plot activity budget ------------
#-----------------------------------------------------------
library(data.table)

setwd("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Activity budget/")
sep15_act<-read.csv("sep15/sep15.csv",header=T,sep=",",row.names=NULL,skip=20)

# sep15
names(sep15_act);head(sep15_act)
sfeed<-sep15_act[,1:2]
#setnames(sfeed,"x","X"); setnames(sfeed,"y","Y")
ssearchi<-sep15_act[,5:6]
# trans overlaps searching in 'diffr' plot (diff bw sep and dec activity)
#strans<-sep15_act[,9:10]
srest<-sep15_act[,13:14]

sep15_act<-as.data.frame(sep15_act)
activity_time<-sfeed$x*(2/60/24)

par(mfrow=c(1,1))

par(new=T)
activity<-sfeed
colvec_a = adjustcolor(c("black"), alpha = 1)
plot(activity_time,activity$y,
     type="s",
     lwd=1,
     ylab="",
     xlab="",
xlim=c(0,max(activity_time)),
ylim=c(0,5000),
col=colvec_a,
axes=F
)


# use if axes = F
actaxis_time<-c("0","1","2","3","4","5","6","7")
actaxis_freq<-c("0","1000","2000","3000","4000","5000")
axis(1,at=c(0:7),labels=actaxis_time)
axis(2,at=c(0,1000,2000,3000,4000,5000),labels=actaxis_freq)
par(new=T); plot(0, type="n",xlab="Days",ylab="Frequency of activity state",axes=F)
box(which="plot")

# nov1
nov1_act<-read.csv("nov1/nov1.csv",header=T,sep=",",row.names=NULL,skip=20)

nfeed<-nov1_act[,1:2]
nsearchi<-nov1_act[,5:6]
#ntrans<-nov1_act[,9:10]
nrest<-nov1_act[,13:14]

# dec15
dec15_act<-read.csv("dec15/dec15.csv",header=T,sep=",",row.names=NULL,skip=20)

dfeed<-dec15_act[,1:2]
dsearchi<-dec15_act[,5:6]
#dtrans<-dec15_act[,9:10]
drest<-dec15_act[,13:14]


# plot difference between time spent in activity states in early vs late season
par(mfrow=c(1,1),mar=c(5,6,5,5),pty="m")
month<-"diffr"
fh<-paste(month,NL_days,mass,NL_shade,NL_food,"_act","",sep="");fh
pdf(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Activity budget/",fh,".pdf",sep=""))
jpeg(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Activity budget/",fh,".jpeg",sep=""))

# plotting order
#rest
#searchi
#feed

par(mfrow=c(1,1),mar=c(5,6,5,5),pty="m")
diffra<-"rest"
diffr<-eval(parse(text=paste("s",diffra,"-","d",diffra,sep="")))

par(new=T)
activity<-diffr
colvec_a = adjustcolor(c("dark green"), alpha = 1)
plot(activity_time,activity$y,
     type="s",
     lwd=1,
     ylab="",
     xlab="",
xlim=c(0,7),
ylim=c(-400,400),
col=colvec_a,
axes=F
)

# find y==0 value (pivotal point when animal switches activity)  ........ under progress
diffr23<-subset(diffr,subset=srest$x * (2 / 60 / 24)==c(2:3))
diffrz<-subset(diffr23,subset=diffr23$y==0)

# use if axes = F
actaxis_time<-c("0","1","2","3","4","5","6","7")
actaxis_freq<-c("-400","-200","0","200","400")
axis(1,at=c(0:7),labels=actaxis_time,las=1)
axis(2,at=c(-400,-200,0,200,400),labels=actaxis_freq,las=1)
mtext("Days",1,line=3)
mtext("Difference in time spent within activity state",2,line=4)
abline(v=2.41111,col="red",lty=3)
box(which="plot")

dev.off()

#------------- reserve plot

par(mfrow=c(1,1))
#Netlogo outputs
setwd("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Reserve plot")

setwd("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/")


reserve<-read.table("sep157800100100_reserve.csv",header=T,sep=",",row.names=NULL,skip=17)
# change for each sim month
sep15reserve<-reserve

reserve<-reserve[,1:2]
reserve<-as.data.frame(reserve)
reserve$Time<-reserve$x * (2 / 60 / 24)
plot(reserve$Time,reserve$y, main="Reserve level (J)",xlim=c(0,max(reserve$Time)),xlab="Days",ylab="Reserve level (J)", col="red",las=1,type="l")


#-----------------------------------------------------------
#------------------------ plot movement paths --------------
#-----------------------------------------------------------

# get all food and shade patches
foodh <- NLGetAgentSet(c("pxcor","pycor"),
"patches with [pcolor = green]",
as.data.frame=TRUE,
# df.col.names=c("x","y")
)

foodl <- NLGetAgentSet(c("pxcor","pycor"),
"patches with [pcolor = yellow]",
as.data.frame=TRUE,
)

shadep1 <- NLGetAgentSet(c("pxcor","pycor"),
"patches with [pcolor = black]",
as.data.frame=TRUE,
)

shadep2 <- NLGetAgentSet(c("pxcor","pycor"),
"patches with [pcolor = black + 2]",
as.data.frame=TRUE,
)

# remove NA's
foodh<-na.omit(foodh)
foodl<-na.omit(foodl)

shadeall<-rbind(shadep1,shadep2)
foodall<-rbind(foodh,foodl)


 #x.minmax <- NLReport("(list min-pxcor max-pxcor)")
 #y.minmax <- NLReport("(list min-pycor max-pycor)")

# retrieve turtle location
#liz <- NLGetAgentSet(c("xcor","ycor"),
# "turtles","pd",
# as.data.frame=TRUE,
#)
#par(new=T)
# plot(liz, xlim=x.minmax, ylim=y.minmax,col="red", pch=19)

# ------------ formatting data

setwd("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Movement trajectories/")

# -----sep15
spatialplot<-read.table("sep15/sep15.csv",header=T,sep=",",skip=19)
spatialplot<-as.data.frame(spatialplot); head(spatialplot)
names(spatialplot)
# format data
spen_move<-spatialplot[,1:2];head(spen_move)
sfeed_move<-spatialplot[,5:6];head(sfeed_move)
ssearch_move<-spatialplot[,9:10];head(ssearch_move)
srest_move<-spatialplot[,13:14]; head(srest_move)
#round off food and shade data points
sfeed_move<-round(sfeed_move,0)
srest_move<-round(srest_move,0)

# ------nov1
spatialplot<-read.table("nov1/nov1.csv",header=T,sep=",",skip=19)
spatialplot<-as.data.frame(spatialplot); head(spatialplot)
names(spatialplot)
# format data
npen_move<-spatialplot[,1:2];head(npen_move)
nfeed_move<-spatialplot[,5:6];head(nfeed_move)
nsearch_move<-spatialplot[,9:10];head(nsearch_move)
nrest_move<-spatialplot[,13:14]; head(nrest_move)
#round off food and shade data points
nfeed_move<-round(nfeed_move,0)
nrest_move<-round(nrest_move,0)

# -----dec15
spatialplot<-read.table("dec15/dec15.csv",header=T,sep=",",skip=19)
spatialplot<-as.data.frame(spatialplot); head(spatialplot)
names(spatialplot)
# format data
dpen_move<-spatialplot[,1:2];head(dpen_move)
dfeed_move<-spatialplot[,5:6];head(dfeed_move)
dsearch_move<-spatialplot[,9:10];head(dsearch_move)
drest_move<-spatialplot[,13:14]; head(drest_move)
#round off food and shade data points
dfeed_move<-round(dfeed_move,0)
drest_move<-round(drest_move,0)


# remove NA's
sfeed_move<-na.omit(sfeed_move)


#subset feeding data by food patch type (high or low)
green<-subset(spatialplot[,5:7],color.1==55,select=c(x.1,y.1))
green<-green[,1:2]
yellow<-subset(spatialplot[,5:7],color.1==45,select=c(x.1,y.1))
yellow<-yellow[,1:2]
green<-round(green,0) ;yellow<-round(yellow,0)


# ------------------ plotting all food and shade patches

# plot food patches
# colvec_m = adjustcolor(c("yellow"), alpha = 0.8)
plot(foodl, xlim=c(-25,25), ylim=c(-25,25),pch=22,cex=2,col="grey",bg="yellow",xlab="",ylab="",axes=F)
par(new=T)
plot(foodh, xlim=c(-25,25), ylim=c(-25,25),pch=22, cex=2,col="grey",bg="dark green",xlab="",ylab="",axes=F)
par(new=T) #if plotting food patches above

# plot all shade patches
par(new=T)
plot(shadeall, xlim=c(-25,25), ylim=c(-25,25),pch=22, cex=2,col="grey",bg="black",xlab="",ylab="",axes=F)
par(new=T)

# ------------------- plotting movement paths

# change input to reflect simulation month
par(pty="s")
month<-"sep15"
mr<-"s"
feed_cex<-eval(parse(text=paste("rbind(",mr,"feed_move$x,",mr,"feed_move$y)",sep="")))
rest_cex<-eval(parse(text=paste("rbind(",mr,"rest_move$x,",mr,"rest_move$y)",sep="")))
str(feed_cex)
tail(sfeed_move)
# feed_cex<-rbind(sfeed_move$x,sfeed_move$y);feed_cex
# rest_cex<-rbind(srest_move$x,srest_move$y)

# remove duplicated elements of matrix
#rest_cex<-rest_cex[, !duplicated(t(rest_cex))]

#export plot to file
fh<-paste(month,NL_days,mass,NL_shade,NL_food,"_move","",sep="");fh
pdf(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Movement trajectories/",fh,".pdf",sep=""))
jpeg(paste("/Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/Movement trajectories/",fh,".jpeg",sep=""))

# feeding
# plot by food level. Uses opposite plot colours.
colvec_m = adjustcolor(c("yellow"), alpha = 0.4)
plot(green,pch=".",cex=feed_cex,xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col=colvec_m,axes=F)
par(new=T)
colvec_m = adjustcolor(c("green"), alpha = 0.4)
plot(yellow,pch=".",cex=feed_cex,xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col=colvec_m,axes=F)
#or plot without food level
par(new=T)
colvec_m = adjustcolor(c("brown"), alpha = 0.4)
plot(sfeed_move,pch=".",cex=feed_cex,xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col=colvec_m,axes=F)

# plot(sfeed_move,pch=".",cex=c(sfeed_move$x),xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col=colvec_m,axes=F)
# par(new=T)
# plot(sfeed_move,pch=".",cex=c(sfeed_move$y),xlim=c(-25,25), ylim=c(-25,25),xlab="",ylab="", col=colvec_m,axes=F)

# searching
par(new=T)
colvec_m = adjustcolor(c("blue"), alpha = 0.5)
plot(ssearch_move,type="l",xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col=colvec_m,axes=F)

# resting
par(new=T)
colvec_m = adjustcolor(c("black"), alpha = 0.8)
plot(srest_move,pch=".",cex=rest_cex,xlim=c(-25,25), ylim=c(-25,25),xlab="",ylab="",col=colvec_m,axes=F)

#plot(srest_move,pch=".",cex=srest_move$y,xlim=c(-25,25), ylim=c(-25,25),xlab="",ylab="",col=colvec_m,axes=F)
#par(new=T)
#plot(srest_move,pch=".",cex=srest_move$x,xlim=c(-25,25), ylim=c(-25,25),xlab="",ylab="",col=colvec_m,axes=F)

# turtle start position
turtle_start<-ssearch_move[1,]
#turtle_start<-data.frame(-8,19)
par(new=T)
plot(turtle_start,pch=8,cex=3,col="pink",xlim=c(-25,25), ylim=c(-25,25),xlab="",ylab="",axes=F)

# use if axes = F
realaxis<-c("-50","-25","0","25","50")
axis(1,at=c(-25,-12.5,0,12.5,25),labels=realaxis)
axis(2,at=c(-25,-12.5,0,12.5,25),labels=realaxis)
par(new=T); plot(0, type="n",xlab="X",ylab="Y",axes=F)
box(which="plot")


dev.off()



# cool random plot
colvec_m = adjustcolor(c("pink","black"), alpha = 0.8)
plot(dsearch_move$x, dsearch_move$y,pch=19,cex=dsearch_move$x,xlim=c(-25,25), ylim=c(-25,25), col=colvec_m,xlab="X coord",ylab="Y coord")




#-----------------------------------------------------------
#------------------------ plot DEB RESULTS -----------------
#-----------------------------------------------------------


colnames(all_results_deb)<-c("hour","E_pres","V_pres","E_H_pres","q_pres","hs_pres","surviv_pres","ms_pres","cumrepro","cumbatch","O2FLUX","CO2FLUX","MLO2","GH2OMET","DEBQMET","DRYFOOD","FAECES","NWASTE","wetgonad","wetstorage","wetfood","wetmass","gutfreemass")
all_results_deb<-as.data.frame(all_results_deb)
plot(all_results_deb$wetmass~all_results_deb$hour,type='l') # Plot mass over time
plot((all_results_deb$gutfreemass-all_results_deb$wetgonad)~all_results_deb$hour,type='l') # plot mass excluding reproduction buffer
plot(all_results_deb$GH2OMET~all_results_deb$hour,type='l') # plot metabolic water over time
plot(all_results_deb$E_pres~all_results_deb$hour,type='l') # Plot reserve density over time







# Lab

VAR<-"ms_pres";VAR<-as.vector(VAR)
par(new=TRUE)
plot(all_results_deb$hour, paste("all_results_deb$",VAR,sep=""),type="l")
eval(parse(text=paste("plot(all_results_deb$hour,all_results_deb$",VAR,",type='l')",sep="")))
VAR
paste("all_results_deb$","ms_pres",sep="")

# Output variables (from str(all_results))
# $ hour       : num  1 2 3 4 5 6 7 8 9 10 ...
# $ E_pres     : num  6813 6806 6806 6806 6806 ...
# $ V_pres     : num  299 300 300 300 300 ...
# $ E_H_pres   : num  137501 137501 137501 137501 137501 ...
# $ q_pres     : num  0.00 2.26e-16 4.52e-16 6.77e-16 9.03e-16 ...
# $ hs_pres    : num  0.00 0.00 2.26e-16 6.77e-16 1.35e-15 ...
# $ surviv_pres: num  1 1 1 1 1 ...
# $ ms_pres    : num  0 334288 334299 334311 334322 ...
# $ cumrepro   : num  0 -11.2 0 -11 0 ...
# $ cumbatch   : num  0 220 439 659 879 ...
# $ O2FLUX     : num  148 177 177 177 177 ...
# $ CO2FLUX    : num  117 140 140 140 140 ...
# $ MLO2       : num  87.7 105 105 105 105 ...
# $ GH2OMET    : num  0.05 0.0599 0.0599 0.0599 0.0599 ...
# $ DEBQMET    : num  0.168 0.18 0.18 0.18 0.18 ...
# $ DRYFOOD    : num  0 0.124 0.124 0.124 0.124 ...
# $ FAECES     : num  0 0.0136 0.0136 0.0136 0.0136 ...
# $ NWASTE     : num  0.0212 0.0254 0.0254 0.0254 0.0254 ...
# $ wetgonad   : num  0 0.0284 0.0598 0.0883 0.1197 ...
# $ wetstorage : num  278 278 278 278 278 ...
# $ wetfood    : num  18.9 18.9 18.9 18.9 18.9 ...
# $ wetmass    : num  596 596 596 596 596 ...
# $ gutfreemass: num  577 577 577 577 577 ...






#----------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------

# Experimental R lab

# 27-1-15
x <- rchisq(100, df = 4)
qqplot(x, qchisq(ppoints(x), df = 4)); abline(0, 1, col = 2, lty = 2)


points(shade.results$Tb~shade.results$tick, type='p', col="blue")

# Replace file with new file name if it already exists

current.file<-'NL turtle Tb with shade.jpg'
if (exists(current.file))
{
  for (i in 1:100){
  replace.file<-i
  new.file<-c(current.file[replace.file],current.file[replace.file+1])
  }

jpeg(paste('NL turtle Tb with shade','new.file','.jpg')
dev.off()
}


# Calling T_opt_lower and T_opt_upper values from NL to create dynamics activity range line in plot

abline(h = c(paste(NLGetAgentSet("T_opt_lower","turtles")),NLGetAgentSet("T_opt_upper","turtles")), col = "red", lty = 3)


# ------ plot function -------

month<-function(sim) {
  sim<-newresults
  par(new=T)
ticktime<-sim$tick * (2 / 60 / 24) # convert to real days
sticktime<-shade.sim$tick * 2 / 60 / 24 # convert to real days
# Plot with title
# with(results,plot(Tb~ticktime,type='l',las=1,xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)")),main=paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")))
with(sim,plot(Tb~ticktime,type='l',las=1,lwd=2,lty=2,col="grey",xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)"))))
shade.sim<-sim[sim$shade %in% 1,]
shade.sim_Tb<-sim[sim$shade %in% 1,'Tb'] ; head(shade.sim_Tb)
#with(results,points(shade.results$Tb~shade.results$tick, type='p', col="blue"))
with(sim,points(shade.sim$Tb~sticktime, type='p', col="lightblue"))
#with(results,points(shade*20~tick,type='p',col="red"))
abline(h = c(NL_T_opt_l,NL_T_opt_u), col = "red", lty = 3)
text(0,28, "Activity range", col = "red", adj = c(.3, 1))
  }

# -------- replace old results -----------
if (exists("results")){
  newones<-sep15plus
  }

ticktime<-newones$tick * (2 / 60 / 24) # convert to real days
shade.newones<-newones[newones$shade %in% 1,]
shade.newones_Tb<-newones[newones$shade %in% 1,'Tb'] ; head(shade.newones_Tb)
sticktime<-shade.newones$tick * 2 / 60 / 24 # convert to real days

# Plot with title
# with(results,plot(Tb~ticktime,type='l',las=1,xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)")),main=paste("From ",daystart," + ",NL_days,"days ;","Weight =",mass,"g ; Shade =", NL_shade,"; Food =", NL_food,"; VTMIN", NL_T_b_min,"C")))
with(newones,plot(Tb~ticktime,type='l',las=1,lwd=2,lty=2,col="grey",xlab="Days",ylab = expression(paste("Body temperature (" * degree,"C)"))))
#with(results,points(shade.results$Tb~shade.results$tick, type='p', col="blue"))
with(newones,points(shade.newones$Tb~sticktime, type='p', col="lightblue"))
#with(results,points(shade*20~tick,type='p',col="red"))
abline(h = c(NL_T_opt_l,NL_T_opt_u), col = "red", lty = 3)
text(0,28, "Activity range", col = "red", adj = c(.3, 1))

# --------------- movement path plots -----------------
# comparing values between sfeed_move and foodh to find high/low food xy coords in sfeed_move and plot on map
# 1.
sfeed_moveh<-data.frame(sfeed_move, foodh[match(sfeed_move, foodh), 2])
sfeed_movel<-data.frame(sfeed_move, foodl[match(sfeed_move, foodl), 2])
names(foodh)
head(sfeed_movel)

#2.
library(compare)
comparisonh <- compare(sfeed_move,foodh,allowAll=TRUE)
sfeed_moveh<-comparisonh$tM
# make df
sfeed_moveh<-as.data.frame(sfeed_moveh); colnames(sfeed_moveh)<-c("x","y")
comparisonh$tM

comparisonl <- compare(sfeed_move,foodl,allowAll=TRUE)
sfeed_movel<-comparisonl$tM
# make df
sfeed_movel<-as.data.frame(sfeed_movel); colnames(sfeed_movel)<-c("x","y")
comparisonl$tM

diff_h <-data.frame(lapply(1:ncol(sfeed_move),function(i)setdiff(sfeed_move[,i],comparisonh$tM[,i])))
colnames(diff_h) <- colnames(sfeed_move)

diff_l <-data.frame(lapply(1:ncol(sfeed_move),function(i)setdiff(sfeed_move[,i],comparisonl$tM[,i])))
colnames(diff_l) <- colnames(sfeed_move)

#2.1.
comparisonh <- compare(foodh,sfeed_move,allowAll=TRUE)
comparisonh$tM; colnames(comparisonh$tM)<-c("x","y")

comparisonl <- compare(foodl,sfeed_move,allowAll=TRUE)
comparisonl$tM; colnames(comparisonl$tM)<-c("x","y")

diff_h <-data.frame(lapply(1:ncol(sfeed_move),function(i)setdiff(sfeed_move[,i],comparisonh$tM[,i])))
colnames(diff_h) <- colnames(sfeed_move)

diff_l <-data.frame(lapply(1:ncol(sfeed_move),function(i)setdiff(sfeed_move[,i],comparisonl$tM[,i])))
colnames(diff_l) <- colnames(sfeed_move)

#3.
library(sqldf)
# select rows of sfeed_move not in foodh
a1NotIna2_h  <- sqldf('SELECT * FROM sfeed_move EXCEPT SELECT * FROM foodh')
a1NotIna2_l  <- sqldf('SELECT * FROM sfeed_move EXCEPT SELECT * FROM foodl')

# select rows from sfeed_move that also appear in foodh
a1Ina2_h  <- sqldf('SELECT * FROM sfeed_move INTERSECT SELECT * FROM foodh')
a1Ina2_l  <- sqldf('SELECT * FROM sfeed_move INTERSECT SELECT * FROM foodl')

# matching plot functions
# high and low food plot
#1.
par(new=T)
plot(sfeed_moveh,pch=".",cex=c(feed_cex),xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col="green",axes=F)
par(new=T)
plot(sfeed_movel,pch=".",cex=c(feed_cex),xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col="yellow",axes=F)

#2.
par(new=T)
plot(diff_h,pch=".",cex=c(feed_cex),xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col="green",axes=F)
par(new=T)
plot(diff_l,pch=".",cex=c(feed_cex),xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col="yellow",axes=F)

#3.
par(new=T)
plot(a1NotIna2_h,pch=".",cex=c(feed_cex),xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col="green",axes=F)
par(new=T)
plot(a1NotIna2_l,pch=".",cex=c(feed_cex),xlim=c(-25,25), ylim=c(-25,25), xlab="",ylab="",col="yellow",axes=F)


# --------------- exporting plots ------------------------
NLCommand("setup")
# need to somehow change working dir
NLCommand("export-plot \"Spatial coordinates of transition between activity states\" \"Users/matthewmalishev/Documents/Manuscripts/Malishev and Kearney/Figures/Simulations/spatialplot.csv\"")

#spatial plot
NLCommand("export-plot \"Spatial coordinates of transition between activity states\" \"Simulations/spatialplot.csv\"")
# reserve plot
NLCommand("export-plot \"Reserve level and starvation reserve over time\" \"Simulations/reserveplot.csv\"")
#temp plot
NLCommand("export-plot \"Body temperature (T_b)\" \"Simulations/tempplot.csv\"")
# activity budget
NLCommand("export-plot \"Global time budget\" \"Simulations/activitybudget.csv\"")
# world view
NLCommand("export-view \"Simulations/worldview.png\"")


# clear all plots
graphics.off()

