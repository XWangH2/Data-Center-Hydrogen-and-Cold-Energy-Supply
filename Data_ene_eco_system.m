function Fun = Data_ene_eco_system(xx)
% DATA_ENE_ECO_SYSTEM Objective function for multi-objective optimization.
%
% Decision variables:
%   xx(1) - Grid electricity supply during off-peak hours
%   xx(2) - Grid electricity supply during peak hours
%   xx(3) - Electricity used by the chiller during off-peak hours
%   xx(4) - Electricity used by the chiller during peak hours
%   xx(5) - Offshore hydrogen supply
%   xx(6) - Offshore cooling supply
%
% Objective functions:
%   Fun(1) - Grid electricity consumption
%   Fun(2) - Total system cost

%% Electricity prices

ele_offpeak = 0.133 * 1.25; % $/kWh, GBP-to-USD
ele_peak = 0.305 * 1.25;


%% Data-center load data

filename = 'Data_center_energy.xlsx';
sheetname = 'Sheet1';

% Import load data
data = readtable(filename, 'Sheet', sheetname);

COP_Chiller = 5;

% Representative 24-hour load profile
T1 = data(1:24, 1);       % Total load
P1 = data(1:24, 2);       % Electricity load
C1 = data(1:24, 3);       % Cooling load

T = table2array(T1);
P = table2array(P1);
C = table2array(C1);

% 1-7 and 23-24: off-peak hours
% 8-22: peak hours

P_Time1 = sum(P(1:7,1)) + sum(P(23:24,1));
P_Time2 = sum(P(8:22,1));

C_Time1 = sum(C(1:7,1)) + sum(C(23:24,1));
C_Time2 = sum(C(8:22,1));

%% PEMFC and electric-chiller capacities

P_PEMFC_1 = (P_Time1 - xx(1)) / 9;
P_PEMFC_2 = (P_Time2 - xx(2)) / 15;

P_Chiller_1 = xx(3) / 9;
P_Chiller_2 = xx(4) / 15;

% PEMFC installed capacity
P_PEMFC = max(P_PEMFC_1, P_PEMFC_2);

% Chiller installed electrical-input capacity
P_Chiller = max(P_Chiller_1, P_Chiller_2);

day = 330;

%% Energy supplied by different pathways

Power_grid = xx(1) + xx(2);
Cool_P_grid = xx(3) + xx(4);

Hydrogen_offshore = xx(5);
Cool_offshore = xx(6);

%% Hydrogen and cooling cost models

Cost_Hydrogen = Hydrogen_costform_wind();
Cost_cool = Cooling_costfrom_wind();

% Cooling cost associated with offshore hydrogen production
Cost_Cooling_SOEC_liBr = ...
    xx(5) * Cost_Hydrogen(2) * Cost_Hydrogen(3);

%% Capital cots at data-center side

Year = 20;
Rate = 0.03;

CRF = (Rate * (1 + Rate)^Year) / ...
      ((1 + Rate)^Year - 1);

Rate_main = 1.06;

C_PEMFC = 650; 

clc_PEMFC = ...
    (Rate_main * C_PEMFC * P_PEMFC * CRF) / day;

C_chiller = 216;         % Representative chiller capital cost 

clc_chiller = ...
    (Rate_main * C_chiller * P_Chiller * ...
     CRF * COP_Chiller) / day;

%% Objective 1: Grid energy consumption

Energy_consumption = Power_grid + Cool_P_grid;

%% Grid electricity cost

Peak_price_off = ...
    (xx(1) + xx(3)) * ele_offpeak;

Peak_price = ...
    (xx(2) + xx(4)) * ele_peak;

%% Objective 2: Total system cost

Cost = ...
    Peak_price_off + ...
    Peak_price + ...
    Hydrogen_offshore * Cost_Hydrogen(1) + ...
    Cool_offshore * COP_Chiller * Cost_cool(1) + ...
    clc_chiller + ...
    clc_PEMFC + ...
    Cost_Cooling_SOEC_liBr;

%% Return objective-function values

Fun = [Energy_consumption, Cost];

end