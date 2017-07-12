onelump_varenv<-function (t = seq(1, 3600, 60), time = 0, Tc_init = 5, thresh = 29, 
    AMASS = 500, lometry = 2, Tairf = Tairfun, Tradf = Tradfun, 
    velf = velfun, Qsolf = Qsolfun, Zenf = Zenfun, Flshcond = 0.5, 
    q = 0, Spheat = 3073, EMISAN = 0.95, rho = 932, ABS = 0.85, 
    colchange = 0, lastt = 0, ABSMAX = 0.9, ABSMIN = 0.6, customallom = c(10.4713, 
        0.688, 0.425, 0.85, 3.798, 0.683, 0.694, 0.743), shape_a = 1, 
    shape_b = 0.5, shape_c = 0.5, posture = "n", FATOSK = 0.4, 
    FATOSB = 0.4, sub_reflect = 0.2, PCTDIF = 0.1, press = 101325) 
{
    sigma <- 5.67e-08
    Tair <- Tairf(time + t)
    vel <- velf(time + t)
    Qsol <- Qsolf(time + t)
    Trad <- Tradf(time + t)
    Zen <- Zenf(time + t)
    Zenith <- Zen * pi/180
    Tc <- Tc_init
    Tskin <- Tc + 0.1
    RHskin <- 100
    vel[vel < 0.01] <- 0.01
    abs2 <- ABS
    if (colchange >= 0) {
        abs2 <- min(ABS + colchange * (t - lastt), ABSMAX)
    }
    else {
        abs2 <- max(ABS + colchange * (t - lastt), ABSMIN)
    }
    S2 <- 1e-04
    DENSTY <- 101325/(287.04 * (Tair + 273))
    THCOND <- 0.02425 + (7.038 * 10^-5 * Tair)
    VISDYN <- (1.8325 * 10^-5 * ((296.16 + 120)/((Tair + 273) + 
        120))) * (((Tair + 273)/296.16)^1.5)
    m <- AMASS/1000
    C <- m * Spheat
    V <- m/rho
    Qgen <- q * V
    L <- V^(1/3)
    Flshcond <- 0.5
    if (lometry == 0) {
        ALENTH <- (V/shape_b * shape_c)^(1/3)
        AWIDTH <- ALENTH * shape_b
        AHEIT <- ALENTH * shape_c
        ATOT <- ALENTH * AWIDTH * 2 + ALENTH * AHEIT * 2 + AWIDTH * 
            AHEIT * 2
        ASILN <- ALENTH * AWIDTH
        ASILP <- AWIDTH * AHEIT
        L <- AHEIT
        if (AWIDTH <= ALENTH) {
            L <- AWIDTH
        }
        else {
            L <- ALENTH
        }
        R <- ALENTH/2
    }
    if (lometry == 1) {
        R1 <- (V/(pi * shape_b * 2))^(1/3)
        ALENTH <- 2 * R1 * shape_b
        ATOT <- 2 * pi * R1^2 + 2 * pi * R1 * ALENTH
        AWIDTH <- 2 * R1
        ASILN <- AWIDTH * ALENTH
        ASILP <- pi * R1^2
        L <- ALENTH
        R2 <- L/2
        if (R1 > R2) {
            R <- R2
        }
        else {
            R <- R1
        }
    }
    if (lometry == 2) {
        A1 <- ((3/4) * V/(pi * shape_b * shape_c))^0.333
        B1 <- A1 * shape_b
        C1 <- A1 * shape_c
        P1 <- 1.6075
        ATOT <- (4 * pi * (((A1^P1 * B1^P1 + A1^P1 * C1^P1 + 
            B1^P1 * C1^P1))/3)^(1/P1))
        ASILN <- max(pi * A1 * C1, pi * B1 * C1)
        ASILP <- min(pi * A1 * C1, pi * B1 * C1)
        S2 <- (A1^2 * B1^2 * C1^2)/(A1^2 * B1^2 + A1^2 * C1^2 + 
            B1^2 * C1^2)
        Flshcond <- 0.5 + 6.14 * B1 + 0.439
    }
    if (lometry == 3) {
        ATOT <- (10.4713 * AMASS^0.688)/10000
        AV <- (0.425 * AMASS^0.85)/10000
        ASILN <- (3.798 * AMASS^0.683)/10000
        ASILP <- (0.694 * AMASS^0.743)/10000
        R <- L
    }
    if (lometry == 4) {
        ATOT = (12.79 * AMASS^0.606)/10000
        AV = (0.425 * AMASS^0.85)/10000
        ZEN <- 0
        PCTN <- 1.38171e-06 * ZEN^4 - 0.000193335 * ZEN^3 + 0.00475761 * 
            ZEN^2 - 0.167912 * ZEN + 45.8228
        ASILN <- PCTN * ATOT/100
        ZEN <- 90
        PCTP <- 1.38171e-06 * ZEN^4 - 0.000193335 * ZEN^3 + 0.00475761 * 
            ZEN^2 - 0.167912 * ZEN + 45.8228
        ASILP <- PCTP * ATOT/100
        R <- L
    }
    if (lometry == 5) {
        ATOT = (customallom[1] * AMASS^customallom[2])/10000
        AV = (customallom[3] * AMASS^customallom[4])/10000
        ASILN = (customallom[5] * AMASS^customallom[6])/10000
        ASILP = (customallom[7] * AMASS^customallom[8])/10000
        R <- L
    }
    if (max(Zen) >= 90) {
        Qnorm <- 0
    }
    else {
        Qnorm <- (Qsol/cos(Zenith))
    }
    if (Qnorm > 1367) {
        Qnorm <- 1367
    }
    if (posture == "p") {
        Qabs <- (Qnorm * (1 - PCTDIF) * ASILP + Qsol * PCTDIF * 
            FATOSK * ATOT + Qsol * sub_reflect * FATOSB * ATOT) * 
            abs2
    }
    if (posture == "n") {
        Qabs <- (Qnorm * (1 - PCTDIF) * ASILN + Qsol * PCTDIF * 
            FATOSK * ATOT + Qsol * sub_reflect * FATOSB * ATOT) * 
            abs2
    }
    if (posture == "b") {
        Qabs <- (Qnorm * (1 - PCTDIF) * (ASILN + ASILP)/2 + Qsol * 
            PCTDIF * FATOSK * ATOT + Qsol * sub_reflect * FATOSB * 
            ATOT) * abs2
    }
    Rrad <- ((Tskin + 273) - (Trad + 273))/(EMISAN * sigma * 
        (FATOSK + FATOSB) * ATOT * ((Tskin + 273)^4 - (Trad + 
        273)^4))
    Rrad <- 1/(EMISAN * sigma * (FATOSK + FATOSB) * ATOT * ((Tc + 
        273)^2 + (Trad + 273)^2) * ((Tc + 273) + (Trad + 273)))
    Re <- DENSTY * vel * L/VISDYN
    PR <- 1005.7 * VISDYN/THCOND
    if (lometry == 0) {
        NUfor <- 0.102 * Re^0.675 * PR^(1/3)
    }
    if (lometry == 3 | lometry == 5) {
        NUfor <- 0.35 * Re^0.6
    }
    if (lometry == 1) {
        if (Re < 4) {
            NUfor = 0.891 * Re^0.33
        }
        else {
            if (Re < 40) {
                NUfor = 0.821 * Re^0.385
            }
            else {
                if (Re < 4000) {
                  NUfor = 0.615 * Re^0.466
                }
                else {
                  if (Re < 40000) {
                    NUfor = 0.174 * Re^0.618
                  }
                  else {
                    if (Re < 4e+05) {
                      NUfor = 0.0239 * Re^0.805
                    }
                    else {
                      NUfor = 0.0239 * Re^0.805
                    }
                  }
                }
            }
        }
    }
    if (lometry == 2 | lometry == 4) {
        NUfor <- 0.35 * Re^(0.6)
    }
    hc_forced <- NUfor * THCOND/L
    GR <- abs(DENSTY^2 * (1/(Tair + 273.15)) * 9.80665 * L^3 * 
        (Tskin - Tair)/VISDYN^2)
    Raylei <- GR * PR
    if (lometry == 0) {
        NUfre = 0.55 * Raylei^0.25
    }
    if (lometry == 1 | lometry == 3 | lometry == 5) {
        if (Raylei < 1e-05) {
            NUfre = 0.4
        }
        else {
            if (Raylei < 0.1) {
                NUfre = 0.976 * Raylei^0.0784
            }
            else {
                if (Raylei < 100) {
                  NUfre = 1.1173 * Raylei^0.1344
                }
                else {
                  if (Raylei < 10000) {
                    NUfre = 0.7455 * Raylei^0.2167
                  }
                  else {
                    if (Raylei < 1e+09) {
                      NUfre = 0.5168 * Raylei^0.2501
                    }
                    else {
                      if (Raylei < 1e+12) {
                        NUfre = 0.5168 * Raylei^0.2501
                      }
                      else {
                        NUfre = 0.5168 * Raylei^0.2501
                      }
                    }
                  }
                }
            }
        }
    }
    if (lometry == 2 | lometry == 4) {
        Raylei = (GR^0.25) * (PR^0.333)
        NUfre = 2 + 0.6 * Raylei
    }
    hc_free <- NUfre * THCOND/L
    hc_comb <- hc_free + hc_forced
    Rconv <- 1/(hc_comb * ATOT)
    Nu <- hc_comb * L/THCOND
    hr <- 4 * EMISAN * sigma * ((Tc + Trad)/2 + 273)^3
    hc <- hc_comb
    if (lometry == 2) {
        j <- (Qabs + Qgen + hc * ATOT * ((q * S2)/(2 * Flshcond) + 
            Tair) + hr * ATOT * ((q * S2)/(2 * Flshcond) + Trad))/C
    }
    else {
        j <- (Qabs + Qgen + hc * ATOT * ((q * R^2)/(4 * Flshcond) + 
            Tair) + hr * ATOT * ((q * S2)/(2 * Flshcond) + Trad))/C
    }
    kTc <- ATOT * (Tc * hc + Tc * hr)/C
    k <- ATOT * (hc + hr)/C
    Tcf <- j/k
    Tci <- Tc
    Tc <- (Tci - Tcf) * exp(-1 * k * t) + Tcf
    timethresh <- log((thresh - Tcf)/(Tci - Tcf))/(-1 * k)
    tau <- (rho * V * Spheat)/(ATOT * (hc + hr))
    dTc <- j - kTc
    list(Tc = Tc, Tcf = Tcf, tau = tau, dTc = dTc, abs2 = abs2)
}