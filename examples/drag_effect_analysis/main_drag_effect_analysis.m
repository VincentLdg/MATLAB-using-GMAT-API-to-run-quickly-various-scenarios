time_of_propagation = 10;  % Simulation duration (days)
drag_areas = 15:1:30;  % Drag area (m²)
altitudes_after_10_days = zeros(size(drag_areas)); 

for i = 1:length(drag_areas)
    drag_area = drag_areas(i);
    result = GMAT_Drag_Function(time_of_propagation, drag_area); % Call the function
    altitudes_after_10_days(i) = result(end, 2);  % Get the last altitude
end

% Plot the results
figure;
plot(drag_areas, altitudes_after_10_days, '-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Drag Area (m²)');
ylabel(sprintf('Altitude after %d days (km)', time_of_propagation));
title(sprintf('Evolution of the Altitude after %d days as a function of Drag Area', time_of_propagation));
grid on;

