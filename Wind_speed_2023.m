function specific_wind_speed_1D = Wind_speed_2023(lon_x, lat_y)
% WIND_SPEED_2023 Extract hourly 100-m wind speed from ERA5 data.
%
% Input:
%   lon_x - Longitude of the selected location (degree)
%   lat_y - Latitude of the selected location (degree)
%
% Output:
%   specific_wind_speed_1D - Hourly wind speed at 100 m (m/s)
%
% Wind speed is calculated from the ERA5 100-m wind components:
%
%   V_100 = sqrt(u_100^2 + v_100^2)
%
% ERA5 dataset:
% https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=overview
%
% The original ERA5 NetCDF file is not redistributed in this repository.
% It can be obtained directly from the CDS using the link above.

filename = 'European offshore.nc';

lat = ncread(filename, 'latitude');
lon = ncread(filename, 'longitude');

u100 = ncread(filename, 'u100');
v100 = ncread(filename, 'v100');

wind_speed_100m = sqrt(u100.^2 + v100.^2);

lat_index = find(lat == lat_y);
lon_index = find(lon == lon_x);

specific_wind_speed = wind_speed_100m(lon_index, lat_index, :);

specific_wind_speed_1D = squeeze(specific_wind_speed);

end