% =========================================================================
% Module 2: Multi-Modal Transport Network Manager
% Comprehensive Bangladesh transport system simulation
% =========================================================================

classdef MultiModalTransport < handle
    properties
        metro_network
        bus_network
        launch_network
        fare_systems
        anchor_deployments
    end
    
    methods
        function obj = MultiModalTransport()
            obj.initialize_networks();
            obj.setup_fare_systems();
            obj.deploy_uwb_anchors();
        end
        
        function initialize_networks(obj)
            % Initialize all transport networks
            obj.metro_network = obj.create_metro_network();
            obj.bus_network = obj.create_bus_network();
            obj.launch_network = obj.create_launch_network();
        end
        
        function metro = create_metro_network(obj)
    % create_metro_network - Initializes the Dhaka Metro Rail network structure.

    % General Information
    metro.name = 'Dhaka Metro Rail';
    metro.type = 'Metro';
    
    % Station names
    metro.stations = {
        'Uttara North', 'Uttara Center', 'Uttara South', 'Pallabi', ...
        'Mirpur 11', 'Mirpur 10', 'Kazipara', 'Shewrapara', 'Agargaon', ...
        'Bijoy Sarani', 'Shahbagh', 'Dhaka University', ...
        'Bangladesh Secretariat', 'Motijheel', 'Kamalapur'
    };
    
    % Coordinates (x, y in km from origin)
    metro.coordinates = [
        0, 0;
        1.2, 0;
        2.4, 0;
        3.8, 0;
        5.1, 0;
        6.3, 0;
        7.5, 0;
        8.7, 0;
        10.0, 0;
        11.5, 0;
        13.2, 0;
        14.8, 0;
        16.1, 0;
        17.9, 0;
        19.5, 0
    ];
    
    % Operating characteristics
    metro.capacity_per_train = 1200;
    metro.frequency_minutes = 4;
    metro.avg_speed_kmh = 35;
    metro.operating_hours = [6, 22]; % From 6 AM to 10 PM
    
    % Fare structure (distance-based)
    metro.base_fare = 20;
    metro.per_km_rate = 5;
    metro.max_fare = 100;
end

        
        function bus = create_bus_network(obj)
            % Dhaka Bus Network (Selected major routes)
            bus.name = 'Dhaka Bus Network';
            bus.type = 'Bus';
            
            % Major bus routes
            bus.routes = {
                struct('name', 'Uttara-Motijheel', 'id', 'B001', ...
                       'stops', {{'Uttara', 'Pallabi', 'Mirpur', 'Gabtoli', 'Dhanmondi', 'New Market', 'Motijheel'}}, ...
                       'coordinates', [0,2; 3,1; 6,0; 9,-1; 12,1; 15,0; 18,-1]),
                struct('name', 'Gazipur-Sadarghat', 'id', 'B002', ...
                       'stops', {{'Gazipur', 'Tongi', 'Airport', 'Tejgaon', 'Farmgate', 'Shahbagh', 'Sadarghat'}}, ...
                       'coordinates', [-5,5; -2,3; 2,2; 6,1; 10,0; 14,-1; 18,-3]),
                struct('name', 'Savar-Gulistan', 'id', 'B003', ...
                       'stops', {{'Savar', 'Hemayetpur', 'Shyamoli', 'Kalabagan', 'Azimpur', 'Gulistan'}}, ...
                       'coordinates', [-8,0; -5,1; -1,2; 3,1; 8,0; 12,-1])
            };
            
            % Operating characteristics
            bus.capacity_per_vehicle = 60;
            bus.frequency_minutes = 15;
            bus.avg_speed_kmh = 18; % Dhaka traffic consideration
            bus.operating_hours = [5, 23]; % 5 AM to 11 PM
            
            % Fare structure (zone-based)
            bus.base_fare = 8;
            bus.zone_fare = 5;
            bus.max_fare = 25;
        end
        
        function launch = create_launch_network(obj)
            % River transport (Launch) network
            launch.name = 'Bangladesh Launch Network';
            launch.type = 'Launch';
            
            % Major launch routes
            launch.routes = {
                struct('name', 'Dhaka-Barisal', 'id', 'L001', ...
                       'stops', {{'Sadarghat', 'Chandpur', 'Bhola', 'Barisal'}}, ...
                       'coordinates', [0,0; 25,-15; 45,-25; 65,-35], ...
                       'duration_hours', 8),
                struct('name', 'Dhaka-Patuakhali', 'id', 'L002', ...
                       'stops', {{'Sadarghat', 'Chandpur', 'Patuakhali'}}, ...
                       'coordinates', [0,0; 25,-15; 55,-40], ...
                       'duration_hours', 10),
                struct('name', 'Dhaka-Bhola', 'id', 'L003', ...
                       'stops', {{'Sadarghat', 'Chandpur', 'Bhola'}}, ...
                       'coordinates', [0,0; 25,-15; 45,-25], ...
                       'duration_hours', 6)
            };
            
            % Operating characteristics
            launch.capacity_per_vehicle = 800;
            launch.frequency_hours = 12; % Twice daily
            launch.avg_speed_kmh = 12;
            launch.operating_hours = [6, 20]; % 6 AM to 8 PM
            
            % Fare structure (distance-based)
            launch.base_fare = 50;
            launch.per_km_rate = 2;
            launch.max_fare = 300;
        end
        
        function setup_fare_systems(obj)
            % Initialize fare calculation systems
            obj.fare_systems = struct();
            
            % Metro fare system
            obj.fare_systems.metro = @(origin_idx, dest_idx) obj.calculate_metro_fare(origin_idx, dest_idx);
            
            % Bus fare system  
            obj.fare_systems.bus = @(route_id, origin_idx, dest_idx) obj.calculate_bus_fare(route_id, origin_idx, dest_idx);
            
            % Launch fare system
            obj.fare_systems.launch = @(route_id, origin_idx, dest_idx) obj.calculate_launch_fare(route_id, origin_idx, dest_idx);
        end
        
        function fare = calculate_metro_fare(obj, origin_idx, dest_idx)
            distance = norm(obj.metro_network.coordinates(origin_idx,:) - ...
                          obj.metro_network.coordinates(dest_idx,:));
            fare = obj.metro_network.base_fare + distance * obj.metro_network.per_km_rate;
            fare = min(fare, obj.metro_network.max_fare);
        end
        
        function fare = calculate_bus_fare(obj, route_id, origin_idx, dest_idx)
            zones_crossed = abs(dest_idx - origin_idx);
            fare = obj.bus_network.base_fare + zones_crossed * obj.bus_network.zone_fare;
            fare = min(fare, obj.bus_network.max_fare);
        end
        
        function fare = calculate_launch_fare(obj, route_id, origin_idx, dest_idx)
            % Find the specific route
            route = [];
            for i = 1:length(obj.launch_network.routes)
                if strcmp(obj.launch_network.routes{i}.id, route_id)
                    route = obj.launch_network.routes{i};
                    break;
                end
            end
            
            if isempty(route)
                fare = 0;
                return;
            end
            
            distance = norm(route.coordinates(origin_idx,:) - route.coordinates(dest_idx,:));
            fare = obj.launch_network.base_fare + distance * obj.launch_network.per_km_rate;
            fare = min(fare, obj.launch_network.max_fare);
        end
        
        function deploy_uwb_anchors(obj)
            % Deploy UWB anchors across all transport modes
            obj.anchor_deployments = struct();
            
            % Metro anchors (4 anchors per station)
            for i = 1:length(obj.metro_network.stations)
                station_pos = obj.metro_network.coordinates(i,:) * 1000; % Convert to meters
                anchors = [
                    station_pos + [-20, -10]; % Platform left
                    station_pos + [20, -10];  % Platform right  
                    station_pos + [-20, 10];  % Concourse left
                    station_pos + [20, 10]    % Concourse right
                ];
                obj.anchor_deployments.metro.(sprintf('station_%d', i)) = anchors;
            end
            
            % Bus anchors (2 anchors per major stop)
            for route_idx = 1:length(obj.bus_network.routes)
                route = obj.bus_network.routes{route_idx};
                for stop_idx = 1:length(route.stops)
                    stop_pos = route.coordinates(stop_idx,:) * 1000;
                    anchors = [
                        stop_pos + [-5, -5];  % Stop entrance
                        stop_pos + [5, 5]     % Stop exit
                    ];
                    obj.anchor_deployments.bus.(sprintf('route_%d_stop_%d', route_idx, stop_idx)) = anchors;
                end
            end
            
            % Launch anchors (4 anchors per terminal)
            for route_idx = 1:length(obj.launch_network.routes)
                route = obj.launch_network.routes{route_idx};
                for stop_idx = 1:length(route.stops)
                    stop_pos = route.coordinates(stop_idx,:) * 1000;
                    anchors = [
                        stop_pos + [-15, -15]; % Terminal corner 1
                        stop_pos + [15, -15];  % Terminal corner 2
                        stop_pos + [-15, 15];  % Terminal corner 3
                        stop_pos + [15, 15]    % Terminal corner 4
                    ];
                    obj.anchor_deployments.launch.(sprintf('route_%d_stop_%d', route_idx, stop_idx)) = anchors;
                end
            end
        end
        
        function visualize_network(obj, transport_type)
            % Visualize specific transport network
            figure;
            hold on; grid on;
            
            switch transport_type
                case 'metro'
                    coords = obj.metro_network.coordinates;
                    plot(coords(:,1), coords(:,2), 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
                    title('Dhaka Metro Rail Network');
                    
                    % Add station labels
                    for i = 1:length(obj.metro_network.stations)
                        text(coords(i,1), coords(i,2)+0.3, obj.metro_network.stations{i}, ...
                             'HorizontalAlignment', 'center', 'FontSize', 8);
                    end
                    
                case 'bus'
                    colors = ['r', 'g', 'm'];
                    for i = 1:length(obj.bus_network.routes)
                        route = obj.bus_network.routes{i};
                        coords = route.coordinates;
                        plot(coords(:,1), coords(:,2), [colors(i) '-o'], ...
                             'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', route.name);
                    end
                    title('Major Bus Routes in Dhaka');
                    legend('show');
                    
                case 'launch'
                    colors = ['c', 'y', 'k'];
                    for i = 1:length(obj.launch_network.routes)
                        route = obj.launch_network.routes{i};
                        coords = route.coordinates;
                        plot(coords(:,1), coords(:,2), [colors(i) '-s'], ...
                             'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', route.name);
                    end
                    title('Launch Routes from Dhaka');
                    legend('show');
                    
                case 'all'
                    % Metro
                    coords = obj.metro_network.coordinates;
                    plot(coords(:,1), coords(:,2), 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Metro');
                    
                    % Bus routes
                    colors = ['r', 'g', 'm'];
                    for i = 1:length(obj.bus_network.routes)
                        route = obj.bus_network.routes{i};
                        coords = route.coordinates;
                        plot(coords(:,1), coords(:,2), [colors(i) '--^'], ...
                             'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', ['Bus: ' route.name]);
                    end
                    
                    % Launch routes
                    launch_colors = ['c', 'y', 'k'];
                    for i = 1:length(obj.launch_network.routes)
                        route = obj.launch_network.routes{i};
                        coords = route.coordinates;
                        plot(coords(:,1), coords(:,2), [launch_colors(i) ':s'], ...
                             'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', ['Launch: ' route.name]);
                    end
                    
                    title('Complete Multi-Modal Transport Network');
                    legend('show', 'Location', 'best');
            end
            
            xlabel('Distance (km)');
            ylabel('Distance (km)');
            axis equal;
        end
        
        function stats = get_network_statistics(obj)
            % Calculate comprehensive network statistics
            stats = struct();
            
            % Metro statistics
            stats.metro.total_stations = length(obj.metro_network.stations);
            stats.metro.total_length_km = max(obj.metro_network.coordinates(:,1));
            stats.metro.daily_capacity = obj.metro_network.capacity_per_train * ...
                                       (16 * 60 / obj.metro_network.frequency_minutes); % 16 hours operation
            
            % Bus statistics
            stats.bus.total_routes = length(obj.bus_network.routes);
            total_stops = 0;
            total_length = 0;
            for i = 1:length(obj.bus_network.routes)
                route = obj.bus_network.routes{i};
                total_stops = total_stops + length(route.stops);
                coords = route.coordinates;
                for j = 1:size(coords,1)-1
                    total_length = total_length + norm(coords(j+1,:) - coords(j,:));
                end
            end
            stats.bus.total_stops = total_stops;
            stats.bus.total_length_km = total_length;
            stats.bus.daily_capacity = obj.bus_network.capacity_per_vehicle * ...
                                     (18 * 60 / obj.bus_network.frequency_minutes) * stats.bus.total_routes;
            
            % Launch statistics
            stats.launch.total_routes = length(obj.launch_network.routes);
            total_terminals = 0;
            total_length = 0;
            for i = 1:length(obj.launch_network.routes)
                route = obj.launch_network.routes{i};
                total_terminals = total_terminals + length(route.stops);
                coords = route.coordinates;
                for j = 1:size(coords,1)-1
                    total_length = total_length + norm(coords(j+1,:) - coords(j,:));
                end
            end
            stats.launch.total_terminals = total_terminals;
            stats.launch.total_length_km = total_length;
            stats.launch.daily_capacity = obj.launch_network.capacity_per_vehicle * 2 * stats.launch.total_routes; % 2 trips per day
            
            % Overall statistics
            stats.overall.total_anchor_points = length(fieldnames(obj.anchor_deployments.metro)) + ...
                                              length(fieldnames(obj.anchor_deployments.bus)) + ...
                                              length(fieldnames(obj.anchor_deployments.launch));
            stats.overall.total_daily_capacity = stats.metro.daily_capacity + ...
                                                stats.bus.daily_capacity + ...
                                                stats.launch.daily_capacity;
        end
    end
end

% Example usage and testing
function test_multi_modal_transport()
    fprintf('Testing Multi-Modal Transport Network...\n');
    
    % Create transport network
    transport = MultiModalTransport();
    
    % Get and display statistics
    stats = transport.get_network_statistics();
    
    fprintf('\n=== Network Statistics ===\n');
    fprintf('Metro: %d stations, %.1f km, %d daily capacity\n', ...
            stats.metro.total_stations, stats.metro.total_length_km, stats.metro.daily_capacity);
    fprintf('Bus: %d routes, %d stops, %.1f km, %d daily capacity\n', ...
            stats.bus.total_routes, stats.bus.total_stops, stats.bus.total_length_km, stats.bus.daily_capacity);
    fprintf('Launch: %d routes, %d terminals, %.1f km, %d daily capacity\n', ...
            stats.launch.total_routes, stats.launch.total_terminals, stats.launch.total_length_km, stats.launch.daily_capacity);
    fprintf('Total UWB anchor points: %d\n', stats.overall.total_anchor_points);
    fprintf('Total daily passenger capacity: %d\n', stats.overall.total_daily_capacity);
    
    % Test fare calculations
    fprintf('\n=== Sample Fare Calculations ===\n');
    metro_fare = transport.calculate_metro_fare(1, 5);
    fprintf('Metro fare (Station 1 to 5): %.2f BDT\n', metro_fare);
    
    bus_fare = transport.calculate_bus_fare('B001', 1, 4);
    fprintf('Bus fare (Route B001, Stop 1 to 4): %.2f BDT\n', bus_fare);
    
    launch_fare = transport.calculate_launch_fare('L001', 1, 3);
    fprintf('Launch fare (Route L001, Stop 1 to 3): %.2f BDT\n', launch_fare);
    
    % Visualize networks
    transport.visualize_network('all');
end