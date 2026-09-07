clear; close all; clc;

%% ============================================================
% Monte Carlo uncertainty analysis for LCOH
%
% Uncertain parameters:
%
% 1. Point-wise wind-power uncertainty: +/-2%.
% 2. SOEC efficiency: 80%-95%, independently sampled
%    for each hourly operating point.
% 3. Wind CAPEX: -3% / +15%.
% 4. SOEC CAPEX: -15% / +50%.
% 5. MgH2 storage cost: -15% / +50%.
% 6. Annual hydrogen-storage cycling frequency:
%    50-200 cycles/year.
%% ============================================================


%% ---------------- Load wind-power data ----------------
load('Total_electricity.mat');

nCase = 10;


%% ---------------- Base economic inputs ----------------
C_Windfarm_base = 3400;
C_SOEC_base     = 1192;

Cycle_year_base = 100;

Plant_lifetime = 20;

Rate = 0.03;

CRF = (Rate*(1+Rate)^Plant_lifetime) / ...
      ((1+Rate)^Plant_lifetime - 1);

Rate_main = 1.06;

ele_price = 0.25 * 1.26; % GBP TO USD
Ele_de = 1*ele_price; % H2 charging energy cost ($/kg H2), assuming 1 kWh/kg H2


%% ---------------- MgH2-based hydrogen storage ----------------
C_Mg_char_base    = 2500/7.1/1.5;
C_Mg_storage_base = 2500/7.1/1.5;
C_Mg_discha_base  = 1800/7.1/1.5;


%% ---------------- Installed capacities ----------------
Wind_power_rated = 2000;

P_Windfarm = Wind_power_rated * 5;
P_SOEC     = Wind_power_rated * 5;


%% ---------------- Monte Carlo settings ----------------
Nsim = 10000;


%% ---------------- Wind-power uncertainty ----------------
Wind_delta_min = -0.02;
Wind_delta_max =  0.02;


%% ---------------- SOEC efficiency ----------------
Eff_min = 0.80;
Eff_max = 0.95;


%% ---------------- Wind CAPEX ----------------
C_Wind_min = 0.97 * C_Windfarm_base;
C_Wind_max = 1.15 * C_Windfarm_base;


%% ---------------- SOEC CAPEX ----------------
C_SOEC_min = 0.85 * C_SOEC_base;
C_SOEC_max = 1.50 * C_SOEC_base;


%% ---------------- Storage cycling frequency ----------------
Cycle_min = 50;
Cycle_max = 200;


%% ---------------- MgH2 storage-cost uncertainty ----------------
C_Mg_factor_min = 0.85;
C_Mg_factor_max = 1.50;


%% ---------------- Pre-allocation ----------------
LCOH_MC = zeros(Nsim,nCase);

LCOH_mean = zeros(nCase,1);
LCOH_std  = zeros(nCase,1);
LCOH_p5   = zeros(nCase,1);
LCOH_p50  = zeros(nCase,1);
LCOH_p95  = zeros(nCase,1);


rng('shuffle'); % Random initialization; individual Monte Carlo results may vary slightly between runs


%% ============================================================
% Monte Carlo loop
% ============================================================

for icase = 1:nCase

    fprintf('Case %d / %d\n',icase,nCase);

    Wind_power_base = Wind_power(icase,:);

    for isim = 1:Nsim

        %% 1. Point-wise wind-power uncertainty
        wind_delta = Wind_delta_min + ...
            (Wind_delta_max-Wind_delta_min) .* ...
            rand(size(Wind_power_base));

        Wind_power_MC = Wind_power_base .* ...
            (1 + wind_delta);


        %% 2. SOEC efficiency - Uniform
        % Each hourly wind-power point has an independent SOEC efficiency

        Eff_MC = Eff_min + ...
           (Eff_max - Eff_min) .* rand(size(Wind_power_MC));


        %% 3. Hydrogen production
        % HHV of hydrogen
        HHV_H2 = 39.4;    % kWh/kg H2

        % system designed based on 10-MW capacity
        H2_hourly = 5*Wind_power_MC .* Eff_MC ./ HHV_H2; 

        % Annual hydrogen production
        total_H2 = sum(H2_hourly);


        %% 4. Wind CAPEX - Uniform
        C_Wind = C_Wind_min + ...
            (C_Wind_max-C_Wind_min) * rand;


        %% 5. SOEC CAPEX - Uniform
        C_SOEC = C_SOEC_min + ...
            (C_SOEC_max-C_SOEC_min) * rand;


        %% 6. Annual storage cycles - Discrete Uniform
        Cycle_year = randi([Cycle_min,Cycle_max]);


        %% 7. MgH2 storage cost - Uniform
        C_Mg_factor = C_Mg_factor_min + ...
            (C_Mg_factor_max-C_Mg_factor_min) * rand;

        C_Mg_char = ...
            C_Mg_factor * C_Mg_char_base;

        C_Mg_storage = ...
            C_Mg_factor * C_Mg_storage_base;

        C_Mg_discha = ...
            C_Mg_factor * C_Mg_discha_base;


        %% 8. Annualized costs
        clc_Wind = Rate_main * ...
            C_Wind * P_Windfarm * CRF;

        clc_SOEC = Rate_main * ...
            C_SOEC * P_SOEC * CRF;

        clc_charging = ...
            Ele_de * total_H2;

        clc_Mg = Rate_main * ...
            (C_Mg_char + C_Mg_storage + C_Mg_discha) * ...
            CRF * total_H2 / Cycle_year;


        %% 9. LCOH
        LCOH_MC(isim,icase) = ...
            (clc_Wind + clc_SOEC + ...
             clc_Mg + clc_charging) ...
             / total_H2;

    end


    %% Statistics
    LCOH_mean(icase) = mean(LCOH_MC(:,icase));
    LCOH_std(icase)  = std(LCOH_MC(:,icase));

    LCOH_p5(icase)   = prctile(LCOH_MC(:,icase),5);
    LCOH_p50(icase)  = prctile(LCOH_MC(:,icase),50);
    LCOH_p95(icase)  = prctile(LCOH_MC(:,icase),95);


    fprintf(['Finished case %d / %d: mean LCOH = %.6f, ' ...
             'P5 = %.6f, P50 = %.6f, P95 = %.6f\n'], ...
             icase,nCase,...
             LCOH_mean(icase),...
             LCOH_p5(icase),...
             LCOH_p50(icase),...
             LCOH_p95(icase));

end


%% ============================================================
% Probability density functions
% ============================================================

Nxi = 100;

LCOH_min = min(LCOH_MC(:));
LCOH_max = max(LCOH_MC(:));

buff = 0.02 * ...
    (LCOH_max-LCOH_min); % Add a small margin to the KDE evaluation range

xi_common = linspace( ...
    LCOH_min-buff,...
    LCOH_max+buff,...
    Nxi)';

PDF_xi = repmat(xi_common,1,nCase);
PDF_f  = zeros(Nxi,nCase);

for icase = 1:nCase

    PDF_f(:,icase) = ...
        ksdensity(LCOH_MC(:,icase),xi_common);

end


check_int = trapz(xi_common,PDF_f);

disp('Integral of each LCOH PDF (should be approximately 1):');
disp(check_int);


%% ============================================================
% Results
% ============================================================

Results = table( ...
    (1:nCase)',...
    LCOH_mean,...
    LCOH_std,...
    LCOH_p5,...
    LCOH_p50,...
    LCOH_p95,...
    'VariableNames',...
    {'CaseID',...
     'Mean_LCOH',...
     'Std_LCOH',...
     'P5_LCOH',...
     'P50_LCOH',...
     'P95_LCOH'});

disp(Results);


save('LCOH_MC_results.mat',...
     'LCOH_MC',...
     'LCOH_mean',...
     'LCOH_std',...
     'LCOH_p5',...
     'LCOH_p50',...
     'LCOH_p95',...
     'PDF_xi',...
     'PDF_f',...
     'Results');