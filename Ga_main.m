clear
clc

%% ============================================================
% Multi-objective genetic-algorithm optimization
%
% Decision variables:
%   x(1) - Grid electricity supply during off-peak hours
%   x(2) - Grid electricity supply during peak hours
%   x(3) - Electricity supplied to the chiller during off-peak hours
%   x(4) - Electricity supplied to the chiller during peak hours
%   x(5) - Offshore hydrogen supply
%   x(6) - Offshore cooling supply
%
% The optimization minimizes:
%   1. Grid electricity consumption
%   2. Total system cost
%
% The detailed hydrogen and cooling models are called by the
% objective function Data_ene_eco_system().
%
% This code provides the short-term (24-h) implementation of the 
% multi-objective optimization. The long-term optimization follows the same 
% formulation and computational procedure, with the analysis horizon and 
% corresponding time-dependent inputs extended to the monthly scale.
%% ============================================================


%% ---------------- Data-center energy-consumption data ----------------

filename = 'Data_center_energy.xlsx';

sheetname = 'Sheet1';

% Import data-center energy-consumption data
data = readtable(filename, 'Sheet', sheetname);

% Representative 24-hour load profile

COP = 5;

T1 = data(1:24, 1);       % Total energy consumption
P1 = data(1:24, 2);       % Electricity consumption
C1 = data(1:24, 3);       % Cooling energy consumption

T = table2array(T1);

P = table2array(P1);

C = table2array(C1);


% 1-7 and 23-24: off-peak hours
% 8-22: peak hours

P_Time1 = sum(P(1:7,1)) + sum(P(23:24,1));

P_Time2 = sum(P(8:22,1));

C_Time1 = sum(C(1:7,1)) + sum(C(23:24,1));

C_Time2 = sum(C(8:22,1));


%% ---------------- Decision-variable bounds ----------------

ub = [P_Time1 ...
      P_Time2 ...
      C_Time1 ...
      C_Time2 ...
      (P_Time1 + P_Time2) / 33.3 / 0.5 ...
      (C_Time1 + C_Time2)];

lb = [0 0 0 0 0 0];


%% ---------------- Hydrogen-related input ----------------

fun = Hydrogen_costform_wind();


%% ---------------- Random-number seed ----------------

rng(0);


%% ---------------- Linear inequality constraints ----------------

A = [];

b = [];


%% ---------------- Equality constraints ----------------

Aeq = [1 1 0 0 33.3*0.5 0; ...
       0 0 COP COP fun(3) COP];

beq = [sum(P) sum(C)*COP];


%% ---------------- Genetic-algorithm settings ----------------

options = gaoptimset( ...
    'UseParallel', true, ...
    'paretoFraction', 0.5, ...
    'populationsize', 200, ...
    'generation', 300, ...
    'stallGenLimit', 40, ...
    'TolFun', 1e-10, ...
    'PlotFcns', @gaplotpareto);


%% ---------------- Objective function ----------------

fitnessfcn = @Data_ene_eco_system;


%% ---------------- Number of decision variables ----------------

nvars = 6;


%% ---------------- Multi-objective optimization ----------------

[x, faval] = gamultiobj( ...
    fitnessfcn, ...
    nvars, ...
    A, b, ...
    Aeq, beq, ...
    lb, ub, ...
    options);