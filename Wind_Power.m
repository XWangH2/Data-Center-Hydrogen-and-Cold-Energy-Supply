%%%%%%%%%%% Wind data extraction - start %%%%%%%%%%%%%%%

% ERA5 dataset:
% https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=overview
%
% The original ERA5 NetCDF file is not redistributed in this repository.
% It can be obtained directly from the CDS using the link above.

filename = 'European offshore.nc';  % Input NetCDF file


lat = ncread(filename, 'latitude');
lon = ncread(filename, 'longitude');


% Read hourly 100-m wind components
u100 = ncread(filename, 'u100');  
v100 = ncread(filename, 'v100');  

% Calculate wind-speed magnitude
wind_speed = sqrt(u100.^2 + v100.^2);


% Specify the selected location
lat_index = find(lat == 54.5);
lon_index = find(lon == 1);

% Extract the wind-speed time series at the selected location
specific_wind_speed = wind_speed(lon_index, lat_index, :);

specific_wind_speed_1D = squeeze(specific_wind_speed); 

%%%%%%%%%%% Wind data extraction - End %%%%%%%%%%%%%%%

for i = 1:1:8760

    wind_hourly_speed(i) = specific_wind_speed_1D(i);

    Wind_power(i) = Single_wind_power(wind_hourly_speed(i));

end

figure;

x = 1:8760;

% First subplot - hourly wind speed
subplot(2, 1, 1);
plot(x, wind_hourly_speed(1,:), '-o', 'LineWidth', 1.5, 'Color', 'b');
ylabel('Wind Hourly Speed (m/s)');
xlabel('Time (hours)');
title('Wind Hourly Speed');
xlim([0 8760]);
grid on;

% Second subplot - wind power
subplot(2, 1, 2);
plot(x, Wind_power(1,:), '-s', 'LineWidth', 1.5, 'Color', 'r');
ylabel('Wind Power (kW)');
xlabel('Time (hours)');
title('Wind Power');
xlim([0 8760]);
grid on;