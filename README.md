# total-station-sensitivity-analysis
A simple sensitivity analysis of trigonometric leveling with a total station.

![A heatmap showing the zenith-angle-to_slope-distance ratios for all given test conditions.](example_heatmap.png)

## Purpose
This script conducts a sensitivity analysis to examine the effect of zenith angle and slope distance on the resulting error in a vertical distance as observed by a total station. There are two functions defined inline that will perform the analysis analytically and via Monte Carlo analysis. At current, the Monte Carlo function is unused.

## How to use
The user needs to specify the *a priori* standard deviations of the total station to be analyzed, specifically the standard deviation in angular accuracy and the standard deviation of EDM accuracy + ppm error. The user must also specify a range of zenith angles and slope distances to test. These are currently the only two parameters used in the sensitivity analysis.

## Result
The result of the analysis is a heatmap which reports the **zenith-angle-to-slope-distance ratio**, which reports how much greater (ratio > 1) or less (ratio < 1) the zenith angle affects the resulting error. The resulting ratios for all initial test conditions are presented in a heatmap as shown above.

## How it works
Because a total station's measurements of zenith angle and slope distance are not correlated, this analysis uses the special law of propagation of variance (SLOPOV).

### Observation equation and SLOPOV
The simplified observation equation used for this analysis expresses vertical distance $V$ as a function of slope distance $D$ and zenith angle $z$:

$V=D\cos{z}$

Through SLOPOV the variance of $V$ is expressed algebraically as

$\sigma_V^2=\left(\dfrac{\partial{V}}{\partial{D}}\sigma_D\right)^2+\left(\dfrac{\partial{V}}{\partial{z}}\sigma_z\right)^2$

where the partial derivatives of $V$ are 

$\dfrac{\partial{V}}{\partial{D}}=\cos{z}$ and $\dfrac{\partial{V}}{\partial{z}}=D\sin{z}$

and the standard deviations $\sigma_D$ and $\sigma_z$ are assumed to be properties of the total station as reported by the manufacturer. $\sigma_z$ will be the listed value for angle observations. $\sigma_D$ is reported as a constant error $a$ and a range-dependent error, $b$, and is calculated as such:

$\sigma_D=\sqrt{a^2+(D\times b)^2}$

### Expressing the variances as a ratio

For each set of test values for zenith angle $z$ and slope distance $D$, the two components of $\sigma_V^2$ are calculated. The value that is plotted to the final heatmap is the **zenith-angle-to-slope-distance ratio**:

$\left(\dfrac{\partial{V}}{\partial{z}}\sigma_z\right)^2\div \left(\dfrac{\partial{V}}{\partial{D}}\sigma_D\right)^2$

A value of the ratio >1 means that, at the given zenith angle and slope distance, the error in the zenith angle observation $z$ has a greater effect on the resulting vertical distance $V$ than the error in the slope distance observation $D$. For values of the ratio <1, the reverse is true.

## Future work

For a easier-to-comprehend comparison of the ratios in the heatmap, I want to express values <1 as a fraction $1/x$. This would allow more direct comparison of the denominator $x$ with the values of ratios >1.

## Acknowledgements
Víctor Martínez-Cagigal (2022). Custom Colormap (https://www.mathworks.com/matlabcentral/fileexchange/69470-custom-colormap), MATLAB Central File Exchange. Retrieved November 23, 2022.

Charles D. Ghilani and Paul R. Wolf (2009). "Adjustment Computations: Spatial Data Analysis." 4th ed., Wiley & Sons, Hoboken. https://doi.org/10.1002/9780470121498
