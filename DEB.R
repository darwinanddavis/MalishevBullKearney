DEB<-function (step = 1/24, z = 7.997, del_M = 0.242, F_m = 13290 * 
    step, kap_X = 0.85, v = 0.065 * step, kap = 0.886, p_M = 32 * 
    step, E_G = 7767, kap_R = 0.95, k_J = 0.002 * step, E_Hb = 73590, 
    E_Hj = E_Hb, E_Hp = 186500, h_a = 2.16e-11/(step^2), s_G = 0.01, 
    T_REF = 20, TA = 8085, TAL = 18721, TAH = 9E+4, TL = 288, 
    TH = 315, E_0 = 1040000, f = 1, E_sm = 1116, K = 1, andens_deb = 1, 
    d_V = 0.3, d_E = 0.3, d_Egg = 0.3, mu_X = 525000, mu_E = 585000, 
    mu_V = 5e+05, mu_P = 480000, kap_X_P = 0.1, n_X = c(1, 1.8, 
        0.5, 0.15), n_E = c(1, 1.8, 0.5, 0.15), n_V = c(1, 1.8, 
        0.5, 0.15), n_P = c(1, 1.8, 0.5, 0.15), n_M_nitro = c(1, 
        4/5, 3/5, 4/5), clutchsize = 2, clutch_ab = c(0.085, 
        0.7), viviparous = 0, minclutch = 0, batch = 1, lambda = 1/2, 
    VTMIN = 26, VTMAX = 39, ma = 1e-04, mi = 0, mh = 0.5, arrhenius = matrix(data = matrix(data = c(rep(TA, 
        8), rep(TAL, 8), rep(TAH, 8), rep(TL, 8), rep(TH, 8)), 
        nrow = 8, ncol = 5), nrow = 8, ncol = 5), acthr = 1, 
    X = 10, E_pres = 6011.93, V_pres = 3.9752^3, E_H_pres = 73592, 
    q_pres = 0, hs_pres = 0, surviv_pres = 1, Es_pres = 0, cumrepro = 0, 
    cumbatch = 0, p_B_past = 0, stage = 1, breeding = 0, pregnant = 0, 
    Tb = 33) 
{
    q_init <- q_pres
    E_H_init <- E_H_pres
    hs_init <- hs_pres
    fecundity <- 0
    clutches <- 0
    clutchenergy = E_0 * clutchsize
    n_O <- cbind(n_X, n_V, n_E, n_P)
    CHON <- c(12, 1, 16, 14)
    wO <- CHON %*% n_O
    w_V = wO[3]
    M_V <- d_V/w_V
    y_EX<-kap_X*mu_X/mu_E # yield of reserve on food
    y_XE<-1/y_EX # yield of food on reserve
    y_VE<-mu_E*M_V/E_G  # yield of structure on reserve
    y_PX<-kap_X_P*mu_X/mu_P # yield of faeces on food
    y_PE<-y_PX/y_EX # yield of faeces on reserve  0.143382353
    nM <- matrix(c(1, 0, 2, 0, 0, 2, 1, 0, 0, 0, 2, 0, n_M_nitro), 
        nrow = 4)
    n_M_nitro_inv <- c(-1 * n_M_nitro[1]/n_M_nitro[4], (-1 * 
        n_M_nitro[2])/(2 * n_M_nitro[4]), (4 * n_M_nitro[1] + 
        n_M_nitro[2] - 2 * n_M_nitro[3])/(4 * n_M_nitro[4]), 
        1/n_M_nitro[4])
    n_M_inv <- matrix(c(1, 0, -1, 0, 0, 1/2, -1/4, 0, 0, 0, 1/2, 
        0, n_M_nitro_inv), nrow = 4)
    JM_JO <- -1 * n_M_inv %*% n_O
    etaO <- matrix(c(y_XE/mu_E * -1, 0, 1/mu_E, y_PE/mu_E, 0, 
        0, -1/mu_E, 0, 0, y_VE/mu_E, -1/mu_E, 0), nrow = 4)
    w_N <- CHON %*% n_M_nitro
    Tcorr = exp(TA * (1/(273 + T_REF) - 1/(273 + Tb)))/(1 + exp(TAL * 
        (1/(273 + Tb) - 1/TL)) + exp(TAH * (1/TH - 1/(273 + Tb))))
    M_V = d_V/w_V
    p_MT = p_M * Tcorr
    k_Mdot = p_MT/E_G
    k_JT = k_J * Tcorr
    p_AmT = p_MT * z/kap
    vT = v * Tcorr
    E_m = p_AmT/vT
    F_mT = F_m * Tcorr
    g = E_G/(kap * E_m)
    E_scaled = E_pres/E_m
    V_max = (kap * p_AmT/p_MT)^(3)
    h_aT = h_a * Tcorr
    L_T = 0
    L_pres = V_pres^(1/3)
    L_max = V_max^(1/3)
    scaled_l = L_pres/L_max
    kappa_G = (d_V * mu_V)/(w_V * E_G)
    yEX = kap_X * mu_X/mu_E
    yXE = 1/yEX
    yPX = kap_X_P * mu_X/mu_P
    mu_AX = mu_E/yXE
    eta_PA = yPX/mu_AX
    w_X = wO[1]
    w_E = wO[3]
    w_V = wO[2]
    w_P = wO[4]
    if (E_H_pres <= E_Hb) {
        dLdt = (vT * E_scaled - k_Mdot * g * V_pres^(1/3))/(3 * 
            (E_scaled + g))
        V_temp = (V_pres^(1/3) + dLdt)^3
        dVdt = V_temp - V_pres
        rdot = vT * (E_scaled/L_pres - (1 + L_T/L_pres)/L_max)/(E_scaled + 
            g)
    }
    else {
        rdot = vT * (E_scaled/L_pres - (1 + L_T/L_pres)/L_max)/(E_scaled + 
            g)
        dVdt = V_pres * rdot
        if (dVdt < 0) {
            dVdt = 0
        }
    }
    V = V_pres + dVdt
    if (V < 0) {
        V = 0
    }
    svl = V^(0.3333333333333)/del_M * 10
    if (E_H_pres <= E_Hb) {
        Sc = L_pres^2 * (g * E_scaled)/(g + E_scaled) * (1 + 
            ((k_Mdot * L_pres)/vT))
        dUEdt = -1 * Sc
        E_temp = ((E_pres * V_pres/p_AmT) + dUEdt) * p_AmT/(V_pres + 
            dVdt)
        dEdt = E_temp - E_pres
    }
    else {
        if (Es_pres > 1e-07 * E_sm * V_pres) {
            dEdt = (p_AmT * f - E_pres * vT)/L_pres
        }
        else {
            dEdt = (p_AmT * 0 - E_pres * vT)/L_pres
        }
    }
    E = E_pres + dEdt
    if (E < 0) {
        E = 0
    }
    p_M = p_MT * V_pres
    p_J = k_JT * E_H_pres
    if (Es_pres > 1e-07 * E_sm * V_pres) {
        p_A = V_pres^(2/3) * p_AmT * f
    }
    else {
        p_A = 0
    }
    p_X = p_A/kap_X
    p_C = (E_m * (vT/L_pres + k_Mdot * (1 + L_T/L_pres)) * (E_scaled * 
        g)/(E_scaled + g)) * V_pres
    p_R = (1 - kap) * p_C - p_J
    if (E_H_pres < E_Hp) {
        if (E_H_pres <= E_Hb) {
            U_H_pres = E_H_pres/p_AmT
            dUHdt = (1 - kap) * Sc - k_JT * U_H_pres
            dE_Hdt = dUHdt * p_AmT
        }
        else {
            dE_Hdt = (1 - kap) * p_C - p_J
        }
    }
    else {
        dE_Hdt = 0
    }
    E_H = E_H_init + dE_Hdt
    if (E_H_pres >= E_Hp) {
        p_D = p_M + p_J + (1 - kap_R) * p_R
    }
    else {
        p_D = p_M + p_J + p_R
    }
    p_G = p_C - p_M - p_J - p_R
    if ((E_H_pres <= E_Hp) | (pregnant == 1)) {
        p_B = 0
    }
    else {
        if (batch == 1) {
            batchprep = (kap_R/lambda) * ((1 - kap) * (E_m * 
                (vT * V_pres^(2/3) + k_Mdot * V_pres)/(1 + (1/g))) - 
                p_J)
            if (breeding == 0) {
                p_B = 0
            }
            else {
                if (cumrepro < batchprep) {
                  p_B = p_R
                }
                else {
                  p_B = batchprep
                }
            }
        }
        else {
            p_B = p_R
        }
    }
    if (E_H_pres > E_Hp) {
        if (cumrepro < 0) {
            cumrepro = 0
        }
        else {
            cumrepro = cumrepro + p_R * kap_R - p_B_past
        }
    }
    cumbatch = cumbatch + p_B
    if (stage == 2) {
        if (cumbatch < 0.1 * clutchenergy) {
            stage = 3
        }
    }
    if (E_H <= E_Hb) {
        stage = 0
    }
    else {
        if (E_H < E_Hj) {
            stage = 1
        }
        else {
            if (E_H < E_Hp) {
                stage = 2
            }
            else {
                stage = 3
            }
        }
    }
    if (cumbatch > 0) {
        if (E_H > E_Hp) {
            stage = 4
        }
        else {
            stage = stage
        }
    }
    if ((cumbatch > clutchenergy) | (pregnant == 1)) {
        if (viviparous == 1) {
            if ((pregnant == 0) & (breeding == 1)) {
                v_baby = v_init_baby
                e_baby = e_init_baby
                EH_baby = 0
                pregnant = 1
                testclutch = floor(cumbatch/E_0)
                if (testclutch > clutchsize) {
                  clutchsize = testclutch
                  clutchenergy = E_0 * clutchsize
                }
                if (cumbatch < clutchenergy) {
                  cumrepro_temp = cumrepro
                  cumrepro = cumrepro + cumbatch - clutchenergy
                  cumbatch = cumbatch + cumrepro_temp - cumrepro
                }
            }
            if (hour == 1) {
                v_baby = v_baby_init
                e_baby = e_baby_init
                EH_baby = EH_baby_init
            }
            if (EH_baby > E_Hb) {
                if ((Tb < VTMIN) | (Tb > VTMAX)) {
                }
                cumbatch(hour) = cumbatch(hour) - clutchenergy
                repro(hour) = 1
                pregnant = 0
                v_baby = v_init_baby
                e_baby = e_init_baby
                EH_baby = 0
                newclutch = clutchsize
                fecundity = clutchsize
                clutches = 1
                pregnant = 0
            }
        }
        else {
            if ((Tb < VTMIN) | (Tb > VTMAX)) {
            }
            if ((Tb < VTMIN) | (Tb > VTMAX)) {
            }
            testclutch = floor(cumbatch/E_0)
            if (testclutch > clutchsize) {
                clutchsize = testclutch
            }
            cumbatch = cumbatch - clutchenergy
            repro = 1
            fecundity = clutchsize
            clutches = 1
        }
    }
    if (E_H_pres > E_Hb) {
        if (acthr > 0) {
            dEsdt = F_mT * (X/(K + X)) * V_pres^(2/3) * f - 1 * 
                (p_AmT/kap_X) * V_pres^(2/3)
        }
        else {
            dEsdt = -1 * (p_AmT/kap_X) * V_pres^(2/3)
        }
    }
    else {
        dEsdt = -1 * (p_AmT/kap_X) * V_pres^(2/3)
    }
    if (V_pres == 0) {
        dEsdt = 0
    }
    Es = Es_pres + dEsdt
    if (Es < 0) {
        Es = 0
    }
    if (Es > E_sm * V_pres) {
        Es = E_sm * V_pres
    }
    gutfull = Es/(E_sm * V_pres)
    if (gutfull > 1) {
        gutfull = 1
    }
    JOJx = p_A * etaO[1, 1] + p_D * etaO[1, 2] + p_G * etaO[1, 
        3]
    JOJv = p_A * etaO[2, 1] + p_D * etaO[2, 2] + p_G * etaO[2, 
        3]
    JOJe = p_A * etaO[3, 1] + p_D * etaO[3, 2] + p_G * etaO[3, 
        3]
    JOJp = p_A * etaO[4, 1] + p_D * etaO[4, 2] + p_G * etaO[4, 
        3]
    JOJx_GM = p_D * etaO[1, 2] + p_G * etaO[1, 3]
    JOJv_GM = p_D * etaO[2, 2] + p_G * etaO[2, 3]
    JOJe_GM = p_D * etaO[3, 2] + p_G * etaO[3, 3]
    JOJp_GM = p_D * etaO[4, 2] + p_G * etaO[4, 3]
    JMCO2 = JOJx * JM_JO[1, 1] + JOJv * JM_JO[1, 2] + JOJe * 
        JM_JO[1, 3] + JOJp * JM_JO[1, 4]
    JMH2O = JOJx * JM_JO[2, 1] + JOJv * JM_JO[2, 2] + JOJe * 
        JM_JO[2, 3] + JOJp * JM_JO[2, 4]
    JMO2 = JOJx * JM_JO[3, 1] + JOJv * JM_JO[3, 2] + JOJe * JM_JO[3, 
        3] + JOJp * JM_JO[3, 4]
    JMNWASTE = JOJx * JM_JO[4, 1] + JOJv * JM_JO[4, 2] + JOJe * 
        JM_JO[4, 3] + JOJp * JM_JO[4, 4]
    JMCO2_GM = JOJx_GM * JM_JO[1, 1] + JOJv_GM * JM_JO[1, 2] + 
        JOJe_GM * JM_JO[1, 3] + JOJp_GM * JM_JO[1, 4]
    JMH2O_GM = JOJx_GM * JM_JO[2, 1] + JOJv_GM * JM_JO[2, 2] + 
        JOJe_GM * JM_JO[2, 3] + JOJp_GM * JM_JO[2, 4]
    JMO2_GM = JOJx_GM * JM_JO[3, 1] + JOJv_GM * JM_JO[3, 2] + 
        JOJe_GM * JM_JO[3, 3] + JOJp_GM * JM_JO[3, 4]
    JMNWASTE_GM = JOJx_GM * JM_JO[4, 1] + JOJv_GM * JM_JO[4, 
        2] + JOJe_GM * JM_JO[4, 3] + JOJp_GM * JM_JO[4, 4]
    O2FLUX = -1 * JMO2/(T_REF/Tb/24.4) * 1000
    CO2FLUX = JMCO2/(T_REF/Tb/24.4) * 1000
    MLO2 = (-1 * JMO2 * (0.082058 * (Tb + 273.15))/(0.082058 * 
        293.15)) * 24.06 * 1000
    GH2OMET = JMH2O * 18.01528
    #metabolic heat production (Watts) = growth overhead plus dissipation power (maintenance, maturity maintenance,
  #maturation/repro overheads) plus assimilation overheads. correct to 20 degrees so it can be temperature corrected
  #in MET.f for the new guessed Tb
    DEBQMET = ((1 - kappa_G) * p_G + p_D + (p_X - p_A - p_A * 
        mu_P * eta_PA))/3600/Tcorr
    DRYFOOD = -1 * JOJx * w_X
    FAECES = JOJp * w_P
    NWASTE = JMNWASTE * w_N
    if (pregnant == 1) {
        wetgonad = ((cumrepro/mu_E) * w_E)/d_Egg + ((((v_baby * 
            e_baby)/mu_E) * w_E)/d_V + v_baby) * clutchsize
    }
    else {
        wetgonad = ((cumrepro/mu_E) * w_E)/d_Egg + ((cumbatch/mu_E) * 
            w_E)/d_Egg
    }
    wetstorage = ((V * E/mu_E) * w_E)/d_V
    wetfood = Es/21525.37/(1 - 0.18)
    wetmass = V * andens_deb + wetgonad + wetstorage + wetfood
    gutfreemass = V * andens_deb + wetgonad + wetstorage
    potfreemass = V * andens_deb + (((V * E_m)/mu_E) * w_E)/d_V
    dqdt = (q_pres * (V_pres/V_max) * s_G + h_aT) * (E_pres/E_m) * 
        ((vT/L_pres) - rdot) - rdot * q_pres
    if (E_H_pres > E_Hb) {
        q = q_init + dqdt
    }
    else {
        q = 0
    }
    dhsds = q_pres - rdot * hs_pres
    if (E_H_pres > E_Hb) {
        hs = hs_init + dhsds
    }
    else {
        hs = 0
    }
    h_w = ((h_aT * (E_pres/E_m) * vT)/(6 * V_pres^(1/3)))^(1/3)
    dsurvdt = -1 * surviv_pres * hs
    surviv = surviv_pres + dsurvdt
    p_B_past = p_B
    E_pres = E
    V_pres = V
    E_H_pres = E_H
    q_pres = q
    hs_pres = hs
    suriv_pres = surviv_pres
    Es_pres = Es
    deb.names <- c("E_pres", "V_pres", "E_H_pres", "q_pres", 
        "hs_pres", "surviv_pres", "Es_pres", "cumrepro", "cumbatch", 
        "p_B_past", "O2FLUX", "CO2FLUX", "MLO2", "GH2OMET", "DEBQMET", 
        "DRYFOOD", "FAECES", "NWASTE", "wetgonad", "wetstorage", 
        "wetfood", "wetmass", "gutfreemass", "gutfull", "fecundity", 
        "clutches")
    results_deb <- c(E_pres, V_pres, E_H_pres, q_pres, hs_pres, 
        surviv_pres, Es_pres, cumrepro, cumbatch, p_B_past, O2FLUX, 
        CO2FLUX, MLO2, GH2OMET, DEBQMET, DRYFOOD, FAECES, NWASTE, 
        wetgonad, wetstorage, wetfood, wetmass, gutfreemass, 
        gutfull, fecundity, clutches)
    names(results_deb) <- deb.names
    return(results_deb)
}


