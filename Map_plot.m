%% ---------------- Coastline data ----------------
% Coastline data are obtained from the Global Self-consistent,
% Hierarchical, High-resolution Geography Database (GSHHG).
%
% The GSHHG data are not redistributed in this repository.
% The low-resolution coastline file "gshhs_l.b" can be obtained
% from the official GSHHG data source:
% https://www.soest.hawaii.edu/pwessel/gshhg/
%
% GSHHG is used only for coastline and land-area visualization
% and does not affect the numerical results of the analysis.

%% ============================================================
% Plot spatial distribution of wind speed
%
% Input:
%   Results_wind - Spatial wind-speed data
%
% The code generates a filled contour map for the selected
% European region.
%% ============================================================
clear
clc

%% ---------------- Geographic grid ----------------

[lon1, lat1] = meshgrid(-15:0.25:15, 60:-0.25:45);

load('Results_wind_speed');

wind_speed_xxx = Results_wind';

%% ---------------- Create map ----------------

figure;

axesm('MapProjection', 'mercator', ...
      'MapLatLimit', [45 60], ...
      'MapLonLimit', [-15 15]);

gridm off;
box off;
framem on;

% Remove coordinate-axis tick marks
set(gca, 'xtick', [], 'ytick', []);

%% ---------------- Load GSHHS shoreline data ----------------

S = gshhs('gshhs_l.b');

%% ---------------- Filled contour map ----------------

hold on;

num_contours_filled = 40;

[C, h] = contourfm( ...
    lat1, ...
    lon1, ...
    wind_speed_xxx, ...
    num_contours_filled, ...
    'LineStyle', 'none');

% Wind-speed color map
colormap("gray");

%% ---------------- Colorbar settings ----------------

% Wind-speed contour levels
contour_levels = [ ...
    5, 5.5, 6, 6.5, 7, 7.5, ...
    8, 8.5, 9, 9.5, 10, 10.5, 11];

% Other contour-level settings used in previous analyses:
%contour_levels = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6]; % CF
%contour_levels = [3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5]; % LCOH
%contour_levels = [0.111, 0.112, 0.113, 0.114, 0.115, ...
%                  0.116, 0.117, 0.118, 0.119, 0.120]; % LCOCE

caxis([min(contour_levels), max(contour_levels)]);

h_colorbar = colorbar( ...
    'Ticks', contour_levels, ...
    'TickLabels', { ...
        '<5.0', '5.5', '6.0', '6.5', '7.0', '7.5', ...
        '8.0', '8.5', '9.0', '9.5', '10.0', '10.5', '>11.0'});

set(h_colorbar, 'FontSize', 18);

%% ---------------- Contour lines ----------------

num_contours_lines = 20;

contourm( ...
    lat1, ...
    lon1, ...
    wind_speed_xxx, ...
    num_contours_lines, ...
    'LineColor', [0.5, 0.5, 0.5], ...
    'LineWidth', 0.1);

%% ---------------- Fill land areas ----------------

for i = 1:length(S)

    

    if length(S(i).Lat) == length(S(i).Lon)

        if strcmp(S(i).LevelString, 'land')

            % Fill land areas with a light gray-blue color
            geoshow( ...
                S(i).Lat, ...
                S(i).Lon, ...
                'DisplayType', 'polygon', ...
                'FaceColor', [0.9 0.95 1], ...
                'EdgeColor', 'none');

        end
    end
end

%% ---------------- Plot coastlines ----------------

for i = 1:length(S)

    
    if length(S(i).Lat) == length(S(i).Lon)

        plotm( ...
            S(i).Lat, ...
            S(i).Lon, ...
            'k', ...
            'LineWidth', 1);

    end
end