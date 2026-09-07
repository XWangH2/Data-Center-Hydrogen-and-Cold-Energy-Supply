clear; close all; clc;

%% ============================================================
% Monte Carlo uncertainty analysis for LCOCE
%
% Uncertain parameters:
% 1. Point-wise wind-power uncertainty: +/-2%
% 2. Chiller COP: 3-7, independently sampled
%    for each hourly operating point.
% 3. Wind CAPEX: -3% / +15%
% 4. PCM storage cost: -10% / +30%
% 5. Annual PCM-storage cycling frequency: 50-200 cycles/year
%% ============================================================


%% ---------------- Load wind-power data ----------------
load('Total_electricity.mat');

nCase = 10;


%% ---------------- Base economic inputs ----------------
C_Windfarm_base = 3400;
C_PCM_base      = 140;

Cycle_year_base = 100;

Plant_lifetime = 20;

Rate = 0.03;

CRF = (Rate*(1+Rate)^Plant_lifetime) / ...
      ((1+Rate)^Plant_lifetime - 1);

Rate_main = 1.06;

Wind_power_rated = 2000;
P_Windfarm = Wind_power_rated;

C_chiller = 216;  % Representative chiller capital cost


%% ---------------- Monte Carlo settings ----------------
Nsim = 10000;


%% ---------------- Wind-power uncertainty ----------------
Wind_delta_min = -0.02;
Wind_delta_max =  0.02;


%% ---------------- COP uncertainty ----------------
COP_base = 5;

COP_min = 3.0;
COP_max = 7.0;


%% ---------------- Wind CAPEX ----------------
C_Wind_min = 0.97 * C_Windfarm_base;
C_Wind_max = 1.15 * C_Windfarm_base;


%% ---------------- PCM storage cost ----------------
C_PCM_min = 0.90 * C_PCM_base;
C_PCM_max = 1.30 * C_PCM_base;


%% ---------------- PCM storage cycles ----------------
Cycle_min = 50;
Cycle_max = 200;


%% ---------------- Pre-allocation ----------------
LCOCE_MC   = zeros(Nsim,nCase);

LCOCE_mean = zeros(nCase,1);
LCOCE_std  = zeros(nCase,1);

LCOCE_p5   = zeros(nCase,1);
LCOCE_p50  = zeros(nCase,1);
LCOCE_p95  = zeros(nCase,1);


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


        %% 2. COP - Uniform
       COP_MC = COP_min + ...
           (COP_max-COP_min) .* rand(size(Wind_power_MC));

        %% 3. Cold-energy production
        Cold_hourly = Wind_power_MC .* COP_MC;
        
        total_cool = sum(Cold_hourly);

        %% 4. Wind CAPEX - Uniform
        C_Windfarm = C_Wind_min + ...
            (C_Wind_max-C_Wind_min) * rand;


        %% 5. PCM storage cost - Uniform
        C_PCM_cool = C_PCM_min + ...
            (C_PCM_max-C_PCM_min) * rand;


        %% 6. Annual PCM cycles - Discrete Uniform
        Cycle_year = randi([Cycle_min,Cycle_max]);


        %% 7. Chiller installed capacity
        P_chiller_cooling = max(Cold_hourly);

        %% 8. Annualized costs
        clc_Wind = Rate_main .* ...
            C_Windfarm .* P_Windfarm .* CRF;

        clc_chiller = Rate_main .* ...
            C_chiller .* P_chiller_cooling .* CRF;

        clc_PCM = Rate_main .* ...
            C_PCM_cool .* CRF .* ...
            total_cool ./ Cycle_year;


        %% 9. LCOCE
        LCOCE_MC(isim,icase) = ...
            (clc_Wind + clc_chiller + clc_PCM) ...
            ./ total_cool;

    end


    %% Statistics
    LCOCE_mean(icase) = ...
        mean(LCOCE_MC(:,icase));

    LCOCE_std(icase) = ...
        std(LCOCE_MC(:,icase));

    LCOCE_p5(icase) = ...
        prctile(LCOCE_MC(:,icase),5);

    LCOCE_p50(icase) = ...
        prctile(LCOCE_MC(:,icase),50);

    LCOCE_p95(icase) = ...
        prctile(LCOCE_MC(:,icase),95);


    fprintf(['Finished case %d / %d: mean LCOCE = %.6f, ' ...
             'P5 = %.6f, P50 = %.6f, P95 = %.6f\n'], ...
             icase,nCase,...
             LCOCE_mean(icase),...
             LCOCE_p5(icase),...
             LCOCE_p50(icase),...
             LCOCE_p95(icase));

end


%% ============================================================
% Probability density functions
% ============================================================

Nxi = 100;

LCOCE_min_all = min(LCOCE_MC(:));
LCOCE_max_all = max(LCOCE_MC(:));

buff = 0.02 * ...
    (LCOCE_max_all-LCOCE_min_all); % Add a small margin to the KDE evaluation range


xi_common = linspace( ...
    LCOCE_min_all-buff,...
    LCOCE_max_all+buff,...
    Nxi)';

LCOCE_PDF_xi = ...
    repmat(xi_common,1,nCase);

LCOCE_PDF_f = ...
    zeros(Nxi,nCase);


for icase = 1:nCase

    LCOCE_PDF_f(:,icase) = ...
        ksdensity( ...
        LCOCE_MC(:,icase),...
        xi_common);

end


check_int = ...
    trapz(xi_common,LCOCE_PDF_f);

disp('Integral of each LCOCE PDF (should be ~1):');
disp(check_int);


%% ============================================================
% Results
% ============================================================

CaseID = (1:nCase)';

Results = table( ...
    CaseID,...
    LCOCE_mean,...
    LCOCE_std,...
    LCOCE_p5,...
    LCOCE_p50,...
    LCOCE_p95,...
    'VariableNames',...
    {'CaseID',...
     'Mean_LCOCE',...
     'Std_LCOCE',...
     'P5_LCOCE',...
     'P50_LCOCE',...
     'P95_LCOCE'});

disp(Results);


save('LCOCE_MC_V2_results.mat',...
     'LCOCE_MC',...
     'LCOCE_mean',...
     'LCOCE_std',...
     'LCOCE_p5',...
     'LCOCE_p50',...
     'LCOCE_p95',...
     'LCOCE_PDF_xi',...
     'LCOCE_PDF_f',...
     'Results');