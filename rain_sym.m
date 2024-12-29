%% Rain simulator
clc
clear all;
close all;

% -------------------------------------------------------------------------
% the rain box will be the 2D square [0, 30]^2
sym.x0 = 10;
sym.xe = 20;
sym.y0 = 5.5;
sym.ye = 0;
sym.pos_toll = 1;
% the rain will start from the line y = 5.5
% mesh the interval [0, 30] at y = 5.5 into rain.Nr points, that will
% represent the number of rain drop.
a = 0;
b = 30;
rain.Nr = 512;
rain_segment = [linspace(a, b, rain.Nr)', sym.y0.*ones(rain.Nr, 1)];
% define the rain drop y velocity rain.yVr
rain.yVr = -0.150;
% define the rain drop angle rain.theta_r to be the angle that the velocity
% vector of each rain drops forms with the normal vector to the ground.
rain.theta_r = 0;
% coefficient used to weight the effect of the added normal random noise
% used to x_shift the newly generated rain drops
rain_rand_coeff = 0.05;
% enable plot
plot_en = 1;

% parameters of the dummy human:
% will be a 2D rectangle
% the generic human ratio is H = 6*L
human.L = 0.83;
human.H = 5;
human.x_pos = sym.x0 - human.L - sym.pos_toll;
human.vel = 0;
% -------------------------------------------------------------------------

% define parameters range
start_vel = 0.005;
end_vel = 0.3;
start_angle = pi/3;
end_angle = -pi/3;
% define parameters steps
angle_steps = 64;
human_vel_steps = 64;
% compute parameters vectors
vel_vect = linspace(start_vel, end_vel, human_vel_steps);
angle_vect = linspace(start_angle, end_angle, angle_steps);
% define the hit_drops_matrix
hit_drops_matrix = zeros(angle_steps, human_vel_steps);

% sweep the simulation parameters rain angle and human speed
for curr_vel = 1:human_vel_steps
    % assign current velocity
    human.vel = vel_vect(curr_vel);
    for curr_angle = 1:angle_steps
        % assign current angle
        rain.theta_r = angle_vect(curr_angle);
        % reset the status of the system
        human.x_pos = sym.x0 - human.L - sym.pos_toll;
        % compute the velocity vector such that it respect the
        % imposed y velocity and angle theta
        rain.Vr_vect = [rain.yVr/tan(rain.theta_r - pi/2), rain.yVr];
        % define a vector that will hold all the rain drops that will be added 
        % during the storm.
        drops_vect = []; %n_drops x 2 matrix, [x_drop, y_drop]
        % counter that count the number of drops that impact with the dummy human
        hit_drops_cnt = 0;
        
        % start the current simulation
        while(1)
            % update the position of all the rain drops present in the 
            % drops vector using the previously defined velocity vector
            for drop = 1:length(drops_vect)
                drops_vect(drop, :) = drops_vect(drop, :) + rain.Vr_vect;
            end
            % generate new rain drops at y = 1 + normal noise (add random x shift)
            drops_vect = [drops_vect; rain_segment + randn(rain.Nr, 2).*rain_rand_coeff];
        
            % remove all the rain drops that exit the simulation box [0, 1]^2
            drops_vect(drops_vect(:, 2) < sym.ye, :) = [];
        
            % update the position of the dummy human using it's velocity value
            % wait for the simulation box to be full of rain drops
            if(nnz(drops_vect(:, 2) <= human.H) > 0)
                human.x_pos = human.x_pos + human.vel;
            end
        
            % remove all the rain drops that impact the dummy human, 
            % the counts starts only when the human enters the symulation box
            hit_drops = drops_vect(:, 1) > human.x_pos & ...
                        drops_vect(:, 1) < human.x_pos + human.L & ...
                        drops_vect(:, 2) < human.H;
            drops_vect(hit_drops, :) = [];
            if(human.x_pos >= sym.x0 && human.x_pos <= sym.xe)
                hit_drops_cnt = hit_drops_cnt + nnz(hit_drops);
            end
        
            % plot the rain
            if(plot_en)
                % draw the dummy human
                dh = polyshape([human.x_pos, human.x_pos + human.L, human.x_pos + human.L, human.x_pos], ...
                               [0, 0, human.H, human.H]);
                plot(dh);
                hold on;
                text(human.x_pos + human.L/2, 0.01, sprintf(...
                    "hit-drops = %d", hit_drops_cnt), "Rotation", 90);
                % draw the rain drops
                scatter(drops_vect(:, 1), drops_vect(:, 2), 0.75, "filled");
                xline(sym.x0, "k--", LineWidth=1.5);
                xline(sym.xe, "k--", LineWidth=1.5);
                xlim([a, b]);
                ylim([sym.ye, sym.y0]);
                pause(0.01);
                hold off;
            end

            % stop the simulation if we reach the end of the rain segment
            if(human.x_pos >= sym.xe + sym.pos_toll)
                break;
            end
        end
        % save the number of rain drops
        hit_drops_matrix(curr_angle, curr_vel) = hit_drops_cnt;
    end
end

% plot the result
[VEL, THETA] = meshgrid(vel_vect, angle_vect);
figure;
surf(VEL, THETA, hit_drops_matrix);
xlabel("human velocity");
ylabel("rain angle");
