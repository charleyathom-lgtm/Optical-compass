function [az, el, r] = solar_position(dateVec, lat, lon)

%for some obscure reason Marseille seems to be in utc +3 
%to insert the proper date in summer time substract 3 hours to the current
%time (or that of the measurement)

%[az, el, r] = solar_position([2025 4 28 12 0 0], 43.23,5.44); luminy
%coordinates for 3PM

% dateVec = [year month day hour min sec]
% lat, lon in degrees (N/E positive, S/W negative)
% Output:
%   az = azimuth (deg from North, clockwise)
%   el = elevation (deg above horizon)
%   r = distance from Earth to Sun in km

% Convert input to Julian Date
jd = juliandate(datetime(dateVec));

% Time in Julian centuries since J2000
T = (jd - 2451545.0) / 36525;

% Mean anomaly (deg)
M = mod(357.52911 + 35999.05029 * T - 0.0001537 * T^2, 360);

% Mean longitude (deg)
L0 = mod(280.46646 + 36000.76983 * T + 0.0003032 * T^2, 360);

% Sun equation of center
C = (1.914602 - 0.004817*T - 0.000014*T^2)*sind(M) ...
  + (0.019993 - 0.000101*T)*sind(2*M) ...
  + 0.000289*sind(3*M);

% True longitude (deg)
lambda = L0 + C;

% Apparent longitude
omega = 125.04 - 1934.136 * T;
lambda_apparent = lambda - 0.00569 - 0.00478 * sind(omega);

% Obliquity of the ecliptic
epsilon0 = 23.439291 - 0.0130042 * T;
epsilon = epsilon0 + 0.00256 * cosd(omega);

% Sun's right ascension and declination
alpha = atan2d(cosd(epsilon) * sind(lambda_apparent), cosd(lambda_apparent));
delta = asind(sind(epsilon) * sind(lambda_apparent));

% Greenwich Mean Sidereal Time
GMST = mod(280.46061837 + 360.98564736629 * (jd - 2451545), 360);

% Local Sidereal Time
LST = mod(GMST + lon, 360);

% Hour angle
H = mod(LST - alpha, 360);

% Convert to azimuth and elevation
el = asind(sind(lat)*sind(delta) + cosd(lat)*cosd(delta)*cosd(H));
az = atan2d(-sind(H), ...
            tand(delta)*cosd(lat) - sind(lat)*cosd(H));
az = mod(az, 360); % Ensure azimuth is 0–360°

% Distance from Earth to Sun (km)
r = 1.00014 - 0.01671*cosd(M) - 0.00014*cosd(2*M);
r = r * 149597870.7; % AU to km
fprintf('Azimuth: %.2f°, Elevation: %.2f°, Distance: %.0f km\n', az, el, r);
end
