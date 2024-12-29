%% post-process script
clc
clear;
close all;

gem = [
   "#0072bd"; % dark blue
   "#d95319"; % dark orange
   "#edb120"; % dark yellow
   "#7e2f8e"; % dark magenta
   "#77ac30"; % dark green
   "#4dbeee"; % dark blue sky
   "#a2142f"; % dark red blood
   "#ffd60a"; % sunflower yellow
   "#6582fd"; % discord violet
   "#ff453a"; % watermelon red
   "#1fcfbe"; % acquamarina
   "#268cdd"; % light blue
];

% sym input values
sym_x0 = 10;
sym_xe = 20;
obj_L = 0.83;
obj_H = 5;
rain_yV = -0.150; % rain y constant velocity
rain_theta_vect = linspace(pi/3, -pi/3, 64)*(360./(2*pi)); % rain angle vector
body_vx_vect = linspace(0.005, 0.3, 64); % body x velocity vector
% compute the rain x velocity for every rain angle
% rain_xV = rain_yV./tan(rain_theta_vect - pi/2);

% plot the simulation results
load("hit_drops_matrix.mat");
% normalize data wrt road len and dummy body surface
hit_drops_matrix = hit_drops_matrix./max(hit_drops_matrix, [], "all");
[vel_mat, theta_mat] = meshgrid(body_vx_vect, rain_theta_vect);
fig = figure;
s = surf(theta_mat, vel_mat, hit_drops_matrix);
s.EdgeColor = "k";
s.LineStyle = "none";
xtks = linspace(-60, 60, 10);
xtks_vel = rain_yV./tan(xtks*((2*pi)/360) - pi/2);
xticks(xtks);
xticklabels(gca, compose("%.0f°, %.2f m/s", [xtks', xtks_vel']));
yticks(linspace(0.005, 0.3, 10));
colormap(viridis(2^16));
colorbar;
set(gca, "ColorScale", "log");
set(gca, "ZScale", "log");
xlim([-60, 60]);
ylim([0.005, 0.3]);
zlim([0, 1]);
view(2);
xlabel("rain angle $\theta_r$/rain velocity $V_x$", Interpreter = "latex", FontSize = 14);
ylabel("object velocity (m/s)", Interpreter = "latex", FontSize = 14);
zlabel("Normalized rain flux", Interpreter = "latex", FontSize = 14);
title("Normalized rain flux density as func. of rain angle $\theta_r$ and obj. x velocity", Interpreter = "latex", FontSize = 16);

% draw a separation plane when the rain changes direction
min_data = min(hit_drops_matrix, [], "all");
p = patch([0, 0, 0, 0], [0.005, 0.3, 0.3, 0.005], [min_data, min_data, 1, 1], "k");
p.FaceAlpha = 0.25;
p.LineWidth = 1.5;
p.LineStyle = "--";
text(-58, 0.29, 1, "rain in front of object", Interpreter = "latex");
text(2, 0.29, 1, "rain behind object", Interpreter = "latex");
fig.Position = [0, 0, 800, 600];
% pause;
% exportgraphics(fig, "rain_flux_surf_3D.pdf", "ContentType", "image", "Resolution", 600);

% plot a surf cut
fig = figure;
color_indx = 1;
plts = [];
for cut = 1:4:28
    data = sprintf("\\theta_r / V_{r, x} = %.2f°/%.3f m/s", ...
        rain_theta_vect(cut), rain_yV./tan(rain_theta_vect(cut)*((2*pi)/360) - pi/2));
    plts(end+1) = plot(body_vx_vect, hit_drops_matrix(cut, :), LineWidth = 1, Color = gem(color_indx), ...
        DisplayName = data);
    hold on;
    grid on;
    % compute current minima
    indx_min = islocalmin(hit_drops_matrix(cut, :), "MaxNumExtrema", 1);
    scatter(body_vx_vect(indx_min), hit_drops_matrix(cut, indx_min), Marker = "o", ...
        MarkerFaceColor = gem(color_indx), MarkerEdgeColor = gem(color_indx));
    text(body_vx_vect(indx_min), hit_drops_matrix(cut, indx_min), sprintf("%.3f m/s", body_vx_vect(indx_min)));
    color_indx = color_indx + 1;
end
legend(plts);
set(gca, "YScale", "log");
xlabel("object velocity (m/s)", Interpreter="latex", FontSize = 14);
ylabel("Normalized rain flux", Interpreter = "latex", FontSize = 14);
title("Normalized rain flux density for positive $\theta_r$, surf cut", Interpreter = "latex", FontSize = 16);
fig.Position = [0, 0, 800, 600];
% pause;
% exportgraphics(fig, "rain_flux_vx_min.pdf", "ContentType", "vector");

% do a cut in the other direction
fig = figure;
color_indx = 1;
plts = [];
for cut = 1:4:28
    data = sprintf("V_{obj, x} = %.3f m/s", body_vx_vect(cut));
    plts(end+1) = plot(rain_theta_vect, hit_drops_matrix(:, cut), LineWidth = 1, Color = gem(color_indx), ...
        DisplayName = data);
    hold on;
    grid on;
    % compute current minima
    indx_min = islocalmin(hit_drops_matrix(:, cut), "MaxNumExtrema", 1);
    scatter(rain_theta_vect(indx_min), hit_drops_matrix(indx_min, cut), Marker = "o", ...
        MarkerFaceColor = gem(color_indx), MarkerEdgeColor = gem(color_indx));
    text(rain_theta_vect(indx_min), hit_drops_matrix(indx_min, cut), sprintf("%.0f^\\circ", rain_theta_vect(indx_min)));
    color_indx = color_indx + 1;
end
legend(plts);
set(gca, "YScale", "log");
xticks(xtks);
xticklabels(gca, compose("%.0f°, %.2f m/s", [xtks', xtks_vel']));
xlim([-60, 60]);
xlabel("rain angle from ground normal (deg)", Interpreter="latex", FontSize = 14);
ylabel("Normalized rain flux", Interpreter = "latex", FontSize = 14);
title("Normalized rain flux density as func. of $\theta_r$, surf cut", Interpreter = "latex", FontSize = 16);
fig.Position = [0, 0, 800, 600];
pause;
exportgraphics(fig, "rain_flux_theta_min.pdf", "ContentType", "vector");
