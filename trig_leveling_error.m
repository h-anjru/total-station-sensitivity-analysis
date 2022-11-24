% This script conducts a sensitivity analysis to examine the effect of
% zenith angle and slope distance on the resulting error in a vertical
% distance as observed by a total station. There are two functions defined
% inline that will perform the analysis analytically and via Monte Carlo
% analysis. At current, the Monte Carlo function is unused.

% run the analysis with these initial conditions
test_SDs = [50 100 200 500 1000 3000];
test_Zs = [45 60 75 80 85 88];

% manufacturer specifications
% (Total station: Leica TS15)
stdev_EDM = 0.001;          % [m]
ppm_EDM = 1.5;              % ppm
stdev_angular = 0.27E-3;    % [deg] (reported as mgon)

% initialize matrices for results
ratios_to_map = zeros([length(test_SDs), length(test_Zs)]);
stdevs_to_map = zeros([length(test_SDs), length(test_Zs)]);

% iterate through test values
for ii = 1:length(test_SDs)
    for jj = 1:length(test_Zs)
        [ratio, stdev] = trigLevelErrorSA(test_SDs(ii), ...
            test_Zs(jj), stdev_EDM, ppm_EDM, stdev_angular);
        ratios_to_map(ii, jj) = ratio;  % currently unused
        stdevs_to_map(ii, jj) = stdev;
    end
end

% plot a heatmap of results
hmo = heatmap(ratios_to_map);
hmo.Title = 'Zenith to slope distance effect ratio';

% define and apply custom colormap
% identify position [0-1] of unnorm'd ratio = 1
unity = 1 / max(max(ratios_to_map));

positions = [0 1-unity 1];
hex = ['#ff0000'; '#ffffff'; '#0000ff'];
colors = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
map = customcolormap(positions, colors, 256);

hmo.Colormap = jet;
hmo.ColorbarVisible = 'off';

hmo.YLabel = 'Zenith angle [deg]';
hmo.YData = test_Zs;

hmo.XLabel = 'Slope distance [m]';
hmo.XData = test_SDs;

hmo.CellLabelFormat = '%.4f';


function [Z_to_SD_ratio, stdev_VD] = trigLevelErrorSA(init_SD, init_Z, ...
    s_EDM, ppm, s_ang)
% TRIGLEVELERRORSA runs a simple sensitivity analysis on trig leveling to 
%   determine which has the greater effect on the accuracy of trig 
%   leveling: slope distance or zenith angle.
%
% Inputs:
%   init_SD : initial slope distance [m]
%   init_Z  : initial zenith angle [deg]
%   s_EDM   : std. dev. of EDM measurements [m]
%   ppm     : ppm error of EDM measurements [ppm]
%   s_ang   : std. dev. of angular measurements [deg]
%
% Outputs:
%   Z_to_SD_ratio   : ratio of effect of zenith angle compared to slope
%                     distance
%   stdev_VD        : the expected stdev of a vertical distance observed at
%                     the initial values of zenith angle and slope distance
    
    % patial derivatives of vertical distance formula w/r/t SD and Z
    % vertical distance = slope distance * cos(zenith angle)
    d_SD = cosd(init_Z);
    d_Z = init_SD * sind(init_Z);  % technically negative!

    % error function for slope distance observations
    stdev_SD = sqrt(s_EDM^2 + (init_SD * ppm * 1E-6)^2);
    
    % error function for zenith angle observations is identity.

    % analytical std. dev. of vertical distance
    SD_component = d_SD * stdev_SD;
    Z_component = d_Z * deg2rad(s_ang);

    stdev_VD = sqrt(SD_component^2 + Z_component^2);

    Z_to_SD_ratio = Z_component / SD_component;
end


function [Z_to_SD_ratio, stdev_VD] = trigLevelErrorMC(init_SD, init_Z, ...
    trials, s_EDM, ppm, s_ang)
% TRIGLEVELERRORMC runs a simple Monte Carlo simulation on trig leveling to 
%   determine which has the greater effect on the accuracy of trig 
%   leveling: slope distance or zenith angle.
%
% Inputs:
%   init_SD : initial slope distance [m]
%   init_Z  : initial zenith angle [deg]
%   trials  : number of trials for the Monte Carlo simulation
%   s_EDM   : std. dev. of EDM measurements [m]
%   ppm     : ppm error of EDM measurements [ppm]
%   s_ang   : std. dev. of angular measurements [deg]
%
% Outputs:
%   Z_to_SD_ratio   : ratio of effect of zenith angle compared to slope
%                     distance
%   stdev_VD        : the expected stdev of a vertical distance observed at
%                     the initial values of zenith angle and slope distance
        
    % error function for slope distance observations
    stdev_SD = sqrt(s_EDM^2 + (init_SD * ppm * 1E-6)^2);
    
    % error function for zenith angle observations is identity.
    
    % vector of normal distribution of slope distances and zenith angles
    varied_SDs = normrnd(init_SD, stdev_SD, [trials, 1]);
    varied_Zs = normrnd(init_Z, s_ang, [trials, 1]);
    
    % test 1: variance only in SD
    vert_dist_varied_SD = varied_SDs * cosd(init_Z);
    SD_component = std(vert_dist_varied_SD);
    
    % test 2: variance only in zenith angles
    vert_dist_varied_Z = init_SD * cosd(varied_Zs);
    Z_component = std(vert_dist_varied_Z);

    stdev_VD = sqrt(SD_component^2 + Z_component^2);
    
    % ratio of effect
    Z_to_SD_ratio = Z_component / SD_component;
end
