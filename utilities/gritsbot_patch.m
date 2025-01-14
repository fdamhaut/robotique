function [ patch_data ] = gritsbot_patch()
%GRITSBOT_PATCH This is a helper function to generate patches for the
%simulated GRITSbots.  YOU SHOULD NEVER HAVE TO USE THIS FUNCTION.
%
% PATCH_DATA = GRITSBOT_PATCH() generates a struct containing patch data
% for a robot patch.

    % Make it facing 0 rads
    robot_width = 0.11;
    robot_height = 0.1; 
    wheel_width = 0.02; 
    wheel_height = 0.04;
    led_size = 0.01; 
    
    % Radius of circle
    ATTACK_RANGE = 0.5;
    DETECTION_RANGE = 0.05;
    % Number of trapeze per circle
    % the higher the number, the smaller the width of the circle
    % disable the circle if equal to 0
    ite_circle_attack = 70;
    ite_circle_detection = 0;
    
    % Helper functions to generate vertex coordinates for a centered
    % rectangle and a helper function to shift a rectangle.
    rectangle = @(w, h) [w/2 h/2 1; -w/2 h/2 1; -w/2 -h/2 1; w/2 -h/2 1];
    shift = @(r, x, y) r + repmat([x, y, 0], size(r, 1), 1);
    
    function cir = circle(r, ite)
        out = 0:ite-1;
        form = @(x) [x-2 x-1 x+1 x+2];
        out = cell2mat(arrayfun(form, out, 'UniformOutput', false));
        out = out .* 2*pi/ite;
        sc1 = @(x) [sin(x)*r cos(x)*r 1];
        cir = transpose(reshape(cell2mat(arrayfun(sc1, out, 'UniformOutput', false)), 3, []));
    end
    
    % Create vertices for body, wheel, and led.
    body = rectangle(robot_width, robot_height);
    wheel = rectangle(wheel_width, wheel_height);
    led = rectangle(led_size, led_size);
    attack_range = circle(ATTACK_RANGE, ite_circle_attack);
    detection_range = circle(DETECTION_RANGE, ite_circle_detection);
    
    % Use pre-generated vertices and shift them around to create a robot
    left_wheel = shift(wheel, -(robot_width + wheel_width)/2, -robot_height/6);
    right_wheel = shift(wheel, (robot_width + wheel_width)/2, -robot_height/6);
    left_led = shift(led,  robot_width/8, robot_height/2 - 2*led_size);
    right_led = shift(led,  robot_width/4, robot_height/2 - 2*led_size);
    
    % Putting all the robot vertices together
    vertices = [
     body ; 
     left_wheel; 
     right_wheel;
     left_led;
     right_led;
     attack_range;
     detection_range
    ];

    % Only color the body of the robot.  Everything else is black.
    colors = [
     [238, 138, 17]/255; 
     0 0 0;
     0 0 0;
     0 0 0;
     0 0 0;
    ];
    % Color of attack circle, red by default
    colors = cat(1, colors, repmat([1 0 0], ite_circle_attack, 1));
    % Color of detection circle, blue by default
    colors = cat(1, colors, repmat([0 0 1], ite_circle_detection, 1));

    % This seems weird, but it basically tells the patch function which
    % vertices to connect.
    faces = repmat([1 2 3 4 1], 5+ite_circle_attack+ite_circle_detection, 1);
    
    for i = 2:5+ite_circle_attack+ite_circle_detection
       faces(i, :) = faces(i, :) + (i-1)*4;
    end
    
   patch_data = []; 
   patch_data.vertices = vertices;
   patch_data.colors = colors;
   patch_data.faces = faces;
end

