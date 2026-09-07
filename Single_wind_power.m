function Power = Single_wind_power(V_wind)
% SINGLE_WIND_POWER Calculate hourly wind-turbine output power.
%
% Input:
%   V_wind1 - 100-m wind speed (m/s)
%
% Output:
%   Power - Wind-turbine output power (kW)
%
% The wind-turbine power model is based on the adopted Vestas-80 2 MW
% wind-turbine formulation and uses a piecewise wind-speed relationship.
%
% Key wind-turbine parameters:
%   Air density       = 1.225 kg/m^3
%   Rated power       = 2000 kW
%   Rated wind speed  = 14 m/s
%   Cut-in wind speed = 4 m/s
%   Cut-out wind speed= 25 m/s

%% Wind-turbine parameters
density_air = 1.225;      
Pe_rate = 2000000;           
V_rate = 14;              

% Fitting coefficients
a = 1.25077;
b = 0.234403;
c = -2.92941;

% Dimensionless numerical scaling factor
d = 1.0002;


%% % Overall wind-turbine efficiency
efficiency = (a * b^(V_rate / V_wind)) * ...
             (V_wind / V_rate)^c;

% Efficiency at the rated wind speed
efficiency_0 = (a * b^(V_rate / V_rate)) * ...
               (V_rate / V_rate)^c;

%% Rotor area
% Rotor area is determined from the rated operating condition.
A_rotor = Pe_rate / efficiency_0 / ...
          (0.5 * density_air * V_rate^3);

%% Available wind power
Pw_wind = (0.5 * density_air * A_rotor * V_wind^3);

%% Cut-in and cut-out wind speeds
V_cutin = 4;              
V_cutout = 25;            

%% Piecewise wind-turbine power calculation
if V_wind < V_cutin || V_wind >= V_cutout

    Pe_wind = 0;

elseif V_wind >= V_cutin && V_wind < V_rate

    Pe_wind = efficiency * Pw_wind * d;

else

    Pe_wind = Pe_rate * d;

end

%% Output power
Power = Pe_wind/1000; %kw


end