<img src="https://raw.githubusercontent.com/darwinanddavis/MalishevBullKearney/master/img/mee_header.jpg" alt=" " width=1000 height=400>  

### Matthew Malishev<sup>1,2*</sup>, C. Michael Bull<sup>3</sup> & Michael R. Kearney<sup>2</sup>  

##### _<sup>1</sup> Centre of Excellence for Biosecurity Risk Analysis, <sup>2</sup> School of BioSciences, University of Melbourne, Parkville, Melbourne, 3010, Australia_ 

##### _<sup>3</sup> School of Biological Sciences, Flinders University, Adelaide, 5001, Australia_ 

##### *Corresponding author: matthew.malishev [at] gmail.com     

doi: [![DOI](https://zenodo.org/badge/96968871.svg)](https://zenodo.org/badge/latestdoi/96968871)  
:link: [Malishev M, Michael Bull C, Kearney MR. An individual‐based model of ectotherm movement integrating metabolic and microclimatic constraints. Methods Ecol Evol. 2018;9:472–489.](https://besjournals.onlinelibrary.wiley.com/doi/abs/10.1111/2041-210X.12909)  

******  

Versions:  
 - R 3.5.0  
 - RStudio 1.1.453  
 - JGR 3.4.1  
 - Netlogo 5.3.1    

File extensions:         
.R  
.Rmd  
.nlogo     
.csv    
.pdf  
.rtf  
.html    
  
******

## Abstract  

1.	An understanding of the direct links between animals and their environment can offer insights into the drivers and constraints to animal movement. Constraints on movement interact in complex ways with the physiology of the animal (metabolism) and physical environment (food and weather), but can be modelled using physical principles of energy and mass exchange. Here, we describe a general, spatially explicit individual-based movement model that couples a nutritional energy and mass budget model [Dynamic Energy Budget (DEB) theory] with a biophysical model of heat exchange. This provides a highly integrated method for constraining an ectothermic animal’s movement in response to how food and microclimates vary in space and time.  
2.	The model uses R to drive a NetLogo individual-based model together with microclimate and energy- and mass-budget modelling functions from the R package ‘NicheMapR’. It explicitly incorporates physiological and morphological traits, behavioural thermoregulation, movement strategies, and movement costs. From this, the model generates activity budgets of foraging and shade-seeking, home range behaviour, spatial movement patterns, and life history consequences under user-defined configurations of food and microclimates. To illustrate the model, we run simulations of the Australian sleepy lizard Tiliqua rugosa under different movement strategies (optimising or satisficing) in two contrasting habitats of varying food and shade (sparse and dense). We then compare the results with real, fine-scale movement data of a wild population throughout the breeding season.   
3.	Our results show that 1) the extremes of movement behaviour observed in sleepy lizards are consistent with feeding requirements (passive movement) and thermal constraints (active movement), 2) the model realistically captures majority of the distribution of observed home range size, 3) both satisficing and optimising movement strategies appear to exist in the wild population, but home range size more closely approximates an optimising strategy, and 4) satisficing was more energetically efficient than optimising movement, which returned no additional benefit in metabolic fitness outputs.   
4.	This framework for predicting physical constraints to individual movement can be extended to individual-level interactions with the same or different species and provides new capabilities for forecasting future responses to novel resource and weather scenarios.

** Keywords:** biophysical ecology, dynamic energy budget, individual-based model, microclimate, movement ecology, spatial, thermoregulation    

## Media  

[Where do Animals Spend Their Time and Energy? Theory, Simulations and GPS Trackers Can Help Us Find Out](https://methodsblog.com/2019/05/22/movement-metabolism-microclimate/), Methods Blog, May 22, 2019.  

[British Ecological Society Robert May Prize 2018 shorlisted article](https://besjournals.onlinelibrary.wiley.com/doi/toc/10.1111/(ISSN)2041-210x.ECRAward2018)  

## Future work   

* Predicting how habitat constraints change across life stage  
* Representing geolocation data in 3D space to show limits to dispersal and residence times in space  

<img src="https://raw.githubusercontent.com/darwinanddavis/MalishevBullKearney/master/img/sleepyibm_future.png" alt=" " width=1000 height=600>
Figure 1. Geolocation data of an adult individual at the field site in Bundey Bore, South Australia.  

******  

## :pig: Troubleshooting   

Running JGR and the rJava package in R for Mac OSX El Capitan 10.11.+ is specified in the R model file. If problems persist, feel free to contact me at matthew.malishev [at] gmail.com       
  
For Mac OSX > 10 (El Capitan):  
:one: Override user access to java system files (see [https://stackoverflow.com/questions/30738974/rjava-load-error-in-rstudio-r-after-upgrading-to-osx-yosemite](https://stackoverflow.com/questions/30738974/rjava-load-error-in-rstudio-r-after-upgrading-to-osx-yosemite))
``` unix
sudo ln -s $(/usr/libexec/java_home)/jre/lib/server/libjvm.dylib /usr/local/lib
```  

:two: Install `RNetLogo` and `rJava` packages from source  
:three: Open and run JGR to run model simulation  

This model is optimised to run on Netlogo 5.3.1.  

## Maintainer  
**Matt Malishev**   
:mag: [Website](https://darwinanddavis.github.io/DataPortfolio/)      
:bird: [@darwinanddavis](https://twitter.com/darwinanddavis)    
:email: matthew.malishev [at] gmail.com   


