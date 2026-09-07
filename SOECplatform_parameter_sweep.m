%% ============================================================
% SOEC platform Parameter Sweep Using the Hydrogen Platform Simulink Model
%
% This script performs a parametric simulation of the SOEC system
% by varying the current density and calculating the corresponding
% steam inlet flow rate.
%
% The calculated current density and steam inlet flow rate are
% passed to the Simulink model:
%
% Hydrogen_platform.slx
%
% The Simulink model is then executed for each operating condition.
%% ============================================================

No = 107300;                 % Number of SOEC cells
Cell_area = 0.1 * 0.1;       % Active area of a single cell (m^2)
F = 96485;                   % Faraday constant (C/mol)
SF=0.9;                      % Steam utilization factor; adjustable within the investigated range.

for i = 1:1:59

    Current_density(i) = 1900 + i*100;
    

    Steam_in(i) = ...
        (Current_density(i)/2/F) * Cell_area * No / SF;

    set_param('Hydrogen_platform/SOEC_INPUT/Current', ...
        'value', num2str(Current_density(i)));

    set_param('Hydrogen_platform/Steam_feed/Steam_in', ...
        'value', num2str(Steam_in(i)));


    simOut = sim('Hydrogen_platform');

end

