% =========================================================================
% Single Gate Bus System Simulation
% UWB-based Entry/Exit Control with Zone Detection for Bus Transportation
% Implements bus boarding/alighting mechanism with payment integration
% =========================================================================

classdef SingleGateBusSystem < handle
    properties
        % Gate configuration (single gate for entry/exit)
        gate
        
        % UWB anchor configurations
        zone1_anchors  % Entry/Exit zone (door area)
        zone2_anchors  % Inside bus zone
        
        % Passenger tracking
        active_passengers
        transaction_log
        payment_system
        
        % Bus state management
        bus_state  % IDLE, DOOR_DETECTED, IN_CABIN, TRIP_ACTIVE, NEAR_EXIT, EXIT_CONFIRMED
        gps_tracker
        
        % System statistics
        boarding_stats
        alighting_stats
        security_events
        
        % Configuration parameters
        fare_rates
        detection_threshold
        transaction_timeout
        trip_tracking
    end
    
    methods
        function obj = SingleGateBusSystem()
            obj.initialize_gate_system();
            obj.setup_uwb_anchors();
            obj.initialize_payment_system();
            obj.setup_monitoring_systems();
            obj.initialize_bus_state();
            
            fprintf('🚌 Single Gate Bus System initialized\n');
            fprintf('   Gate: 1 (Entry/Exit) | Zones: 2 (Door + Interior)\n');
        end
        
        function initialize_gate_system(obj)
            % Initialize single gate configuration for bus
            obj.gate = struct(...
                'id', 1, ...
                'status', 'closed', ...  % closed, entry_open, exit_open
                'mode', 'idle', ...      % idle, boarding, alighting
                'current_passenger', [], ...
                'transaction_start_time', [], ...
                'last_activity', datetime('now') ...
            );
        end
        
        function setup_uwb_anchors(obj)
            % Setup UWB anchor positions for bus zones
            
            % Zone 1: Entry/Exit area (door region)
            obj.zone1_anchors = struct(...
                'anchor_1', [0.5, 0.0, 1.8], ...    % Near door bottom
                'anchor_2', [0.5, 0.0, 2.5], ...    % Near door top  
                'anchor_3', [1.0, 0.3, 1.8], ...    % Door step area
                'anchor_4', [1.0, 0.3, 2.5], ...    % Door frame top
                'zone_id', 'BUS_DOOR_ZONE', ...
                'detection_range', 1.2 ...           % meters
            );
            
            % Zone 2: Inside bus area (passenger seating)
            obj.zone2_anchors = struct(...
                'anchor_1', [2.0, 1.0, 1.8], ...    % Front interior
                'anchor_2', [2.0, 1.0, 2.3], ...    % Front ceiling
                'anchor_3', [8.0, 1.0, 1.8], ...    % Rear interior
                'anchor_4', [8.0, 1.0, 2.3], ...    % Rear ceiling
                'zone_id', 'BUS_INTERIOR_ZONE', ...
                'detection_range', 6.0 ...           % meters (bus length)
            );
        end
        
        function initialize_payment_system(obj)
            % Initialize payment processing for bus fares
            obj.payment_system = struct(...
                'base_fare', struct(...
                    'regular', 15, ...     % BDT
                    'student', 8, ...      % BDT  
                    'senior', 10 ...       % BDT
                ), ...
                'distance_rate', 2.0, ...  % BDT per km
                'payment_methods', {{'bus_card', 'mobile_wallet', 'contactless_card', 'cash'}}, ...
                'transaction_fee', 0.5, ... % BDT
                'daily_cap', 50 ...        % BDT maximum per day
            );
            
            obj.fare_rates = obj.payment_system.base_fare;
        end
        
        function setup_monitoring_systems(obj)
            % Initialize monitoring and logging systems
            obj.active_passengers = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            obj.transaction_log = {};
            obj.security_events = {};
            
            obj.boarding_stats = struct(...
                'total_boardings', 0, ...
                'successful_boardings', 0, ...
                'failed_boardings', 0, ...
                'average_boarding_time', 0, ...
                'peak_boarding_rate', 0 ...
            );
            
            obj.alighting_stats = struct(...
                'total_alightings', 0, ...
                'successful_alightings', 0, ...
                'failed_alightings', 0, ...
                'average_alighting_time', 0, ...
                'peak_alighting_rate', 0 ...
            );
            
            obj.detection_threshold = 0.5;  % meters
            obj.transaction_timeout = 30;   % seconds
        end
        
        function initialize_bus_state(obj)
            % Initialize bus state machine and GPS tracking
            obj.bus_state = 'IDLE';
            obj.gps_tracker = struct(...
                'current_location', [23.8103, 90.4125], ... % Dhaka coordinates
                'trip_start_location', [], ...
                'trip_distance', 0, ...
                'speed', 0, ...
                'route_id', 'DEMO_ROUTE_001' ...
            );
            
            obj.trip_tracking = struct(...
                'active_trip', false, ...
                'trip_start_time', [], ...
                'estimated_fare', 0, ...
                'max_trip_distance', 25 ... % km
            );
        end
        
        function result = simulate_passenger_boarding(obj, passenger_id, uwb_device, payment_method)
            % Simulate passenger boarding process
            result = struct('success', false, 'total_time', 0, 'zones_detected', {{}});
            
            try
                % Update bus state
                obj.update_bus_state('DOOR_DETECTED');
                
                % Start boarding transaction
                boarding_start = tic;
                obj.gate.status = 'entry_open';
                obj.gate.mode = 'boarding';
                obj.gate.current_passenger = passenger_id;
                obj.gate.transaction_start_time = datetime('now');
                
                % Zone 1 Detection (Door area)
                zone1_result = obj.detect_passenger_in_zone(uwb_device, obj.zone1_anchors);
                if ~zone1_result.detected
                    result.error_message = 'Zone 1 detection failed: No active UWB device';
                    obj.gate.status = 'closed';
                    obj.gate.mode = 'idle';
                    return;
                end
                
                result.zones_detected{end+1} = 'Bus-Door-Zone';
                fprintf('    📍 Zone 1 detection successful (Accuracy: %.2fcm)\n', zone1_result.accuracy * 100);
                
                % Payment processing at boarding (pay-as-you-board)
                payment_result = obj.process_boarding_payment(payment_method);
                if ~payment_result.success
                    result.error_message = sprintf('Payment failed: %s', payment_result.error);
                    obj.gate.status = 'closed';
                    obj.gate.mode = 'idle';
                    return;
                end
                
                fprintf('    💳 Payment authorized: %.2f BDT\n', payment_result.amount);
                fprintf('    ⚡ Gate opened for boarding\n');
                
                % Simulate boarding time
                pause(0.1 + rand() * 0.5);  % 0.1-0.6 seconds
                
                % Zone 2 Detection (Inside bus)
                zone2_result = obj.detect_passenger_in_zone(uwb_device, obj.zone2_anchors);
                if zone2_result.detected
                    result.zones_detected{end+1} = 'Bus-Interior-Zone';
                    fprintf('    📍 Zone 2 detection successful (Accuracy: %.2fcm)\n', zone2_result.accuracy * 100);
                    
                    % Update bus state to IN_CABIN
                    obj.update_bus_state('IN_CABIN');
                    
                    % Complete boarding
                    obj.complete_boarding_transaction(passenger_id, uwb_device, payment_result);
                    
                    % Start trip tracking if first passenger
                    if length(obj.active_passengers) == 0
                        obj.start_trip_tracking();
                    end
                    
                    result.success = true;
                    result.total_time = toc(boarding_start);
                    result.payment_amount = payment_result.amount;
                    
                    obj.boarding_stats.total_boardings = obj.boarding_stats.total_boardings + 1;
                    obj.boarding_stats.successful_boardings = obj.boarding_stats.successful_boardings + 1;
                else
                    result.error_message = 'Boarding incomplete: Passenger not detected inside bus';
                end
                
                % Reset gate
                obj.gate.status = 'closed';
                obj.gate.mode = 'idle';
                obj.gate.current_passenger = [];
                
            catch ME
                result.error_message = ME.message;
                obj.gate.status = 'closed';
                obj.gate.mode = 'idle';
                obj.boarding_stats.failed_boardings = obj.boarding_stats.failed_boardings + 1;
            end
        end
        
        function result = simulate_passenger_alighting(obj, passenger_id, uwb_device)
            % Simulate passenger alighting process  
            result = struct('success', false, 'total_time', 0, 'zones_detected', {{}});
            
            try
                if ~obj.active_passengers.isKey(passenger_id)
                    result.error_message = 'Passenger not found in active passengers';
                    return;
                end
                
                passenger_data = obj.active_passengers(passenger_id);
                
                % Update bus state
                obj.update_bus_state('NEAR_EXIT');
                
                % Start alighting transaction
                alighting_start = tic;
                obj.gate.status = 'exit_open';
                obj.gate.mode = 'alighting';
                obj.gate.current_passenger = passenger_id;
                obj.gate.transaction_start_time = datetime('now');
                
                % Zone 2 Detection (Moving from inside to door)
                zone2_result = obj.detect_passenger_in_zone(uwb_device, obj.zone2_anchors);
                if zone2_result.detected
                    result.zones_detected{end+1} = 'Bus-Interior-Zone';
                    fprintf('    📍 Interior zone detection successful (Accuracy: %.2fcm)\n', zone2_result.accuracy * 100);
                end
                
                % Calculate final fare based on trip distance
                fare_calculation = obj.calculate_trip_fare(passenger_data);
                
                % Zone 1 Detection (Door area for exit)
                zone1_result = obj.detect_passenger_in_zone(uwb_device, obj.zone1_anchors);
                if ~zone1_result.detected
                    result.error_message = 'Zone 1 detection failed during alighting';
                    obj.gate.status = 'closed';
                    obj.gate.mode = 'idle';
                    return;
                end
                
                result.zones_detected{end+1} = 'Bus-Door-Zone';
                fprintf('    📍 Door zone detection successful (Accuracy: %.2fcm)\n', zone1_result.accuracy * 100);
                
                % Process any additional payment if needed (distance-based)
                additional_payment = 0;
                if fare_calculation.additional_payment > 0
                    additional_payment = fare_calculation.additional_payment;
                    fprintf('    💳 Additional payment processed: %.2f BDT\n', additional_payment);
                end
                
                fprintf('    🚪 Gate opened for alighting\n');
                
                % Simulate alighting time
                pause(0.1 + rand() * 0.3);  % 0.1-0.4 seconds
                
                % Update bus state to EXIT_CONFIRMED
                obj.update_bus_state('EXIT_CONFIRMED');
                
                % Complete alighting transaction
                obj.complete_alighting_transaction(passenger_id, fare_calculation);
                
                result.success = true;
                result.total_time = toc(alighting_start);
                result.fare_calculation = fare_calculation;
                result.additional_payment = additional_payment;
                
                obj.alighting_stats.total_alightings = obj.alighting_stats.total_alightings + 1;
                obj.alighting_stats.successful_alightings = obj.alighting_stats.successful_alightings + 1;
                
                % Reset gate
                obj.gate.status = 'closed';
                obj.gate.mode = 'idle';
                obj.gate.current_passenger = [];
                
                % Return to IDLE state if no more passengers
                if obj.active_passengers.Count == 0
                    obj.update_bus_state('IDLE');
                end
                
            catch ME
                result.error_message = ME.message;
                obj.gate.status = 'closed';
                obj.gate.mode = 'idle';
                obj.alighting_stats.failed_alightings = obj.alighting_stats.failed_alightings + 1;
            end
        end
        
        function zone_result = detect_passenger_in_zone(obj, uwb_device, zone_anchors)
            % Simulate UWB-based passenger detection in specified zone
            zone_result = struct('detected', false, 'accuracy', 0, 'position', []);
            
            if ~uwb_device.active
                return;
            end
            
            % Simulate UWB triangulation with sub-centimeter accuracy
            detection_success = rand() > 0.02; % 98% success rate
            
            if detection_success
                zone_result.detected = true;
                % Simulate sub-centimeter accuracy (0.1-0.4 cm typical)
                zone_result.accuracy = 0.001 + rand() * 0.003; % 0.1-0.4 cm in meters
                
                % Simulate 3D position within zone
                if strcmp(zone_anchors.zone_id, 'BUS_DOOR_ZONE')
                    zone_result.position = [0.7 + rand()*0.3, 0.1 + rand()*0.2, 1.8 + rand()*0.5];
                else % BUS_INTERIOR_ZONE
                    zone_result.position = [2 + rand()*6, 0.5 + rand()*0.5, 1.8 + rand()*0.3];
                end
            end
        end
        
        function payment_result = process_boarding_payment(obj, payment_method)
            % Process payment at boarding (pay-as-you-board model)
            payment_result = struct('success', false, 'amount', 0, 'error', '');
            
            try
                % Get base fare based on passenger type
                base_fare = obj.fare_rates.(payment_method.passenger_type);
                
                % Add transaction fee
                total_amount = base_fare + obj.payment_system.transaction_fee;
                
                % Check balance/payment capability
                if strcmp(payment_method.type, 'cash')
                    % Cash payment always succeeds in demo
                    payment_result.success = true;
                    payment_result.amount = total_amount;
                elseif payment_method.balance >= total_amount
                    payment_result.success = true;
                    payment_result.amount = total_amount;
                    % Deduct from balance (simulated)
                    payment_method.balance = payment_method.balance - total_amount;
                else
                    payment_result.error = 'Insufficient balance';
                    return;
                end
                
            catch ME
                payment_result.error = ME.message;
            end
        end
        
        function complete_boarding_transaction(obj, passenger_id, uwb_device, payment_result)
            % Complete the boarding transaction and add passenger
            
            passenger_data = struct(...
                'passenger_id', passenger_id, ...
                'uwb_device', uwb_device, ...
                'boarding_time', datetime('now'), ...
                'boarding_location', obj.gps_tracker.current_location, ...
                'payment_amount', payment_result.amount, ...
                'trip_start_distance', obj.gps_tracker.trip_distance ...
            );
            
            obj.active_passengers(passenger_id) = passenger_data;
            
            % Log transaction
            transaction = struct(...
                'timestamp', datetime('now'), ...
                'type', 'boarding', ...
                'passenger_id', passenger_id, ...
                'amount', payment_result.amount, ...
                'location', obj.gps_tracker.current_location, ...
                'bus_state', obj.bus_state ...
            );
            
            obj.transaction_log{end+1} = transaction;
        end
        
        function fare_calculation = calculate_trip_fare(obj, passenger_data)
            % Calculate fare based on trip distance
            
            % Simulate trip distance (random for demo)
            trip_distance = 1.5 + rand() * 8.5;  % 1.5-10 km typical bus route
            
            base_fare = passenger_data.payment_amount - obj.payment_system.transaction_fee;
            distance_charge = trip_distance * obj.payment_system.distance_rate;
            total_fare = base_fare + distance_charge;
            
            % Additional payment needed (distance-based)
            additional_payment = max(0, distance_charge);
            
            fare_calculation = struct(...
                'base_fare', base_fare, ...
                'distance_km', trip_distance, ...
                'distance_charge', distance_charge, ...
                'total_fare', total_fare, ...
                'additional_payment', additional_payment ...
            );
        end
        
        function complete_alighting_transaction(obj, passenger_id, fare_calculation)
            % Complete the alighting transaction and remove passenger
            
            % Log alighting transaction
            transaction = struct(...
                'timestamp', datetime('now'), ...
                'type', 'alighting', ...
                'passenger_id', passenger_id, ...
                'total_fare', fare_calculation.total_fare, ...
                'trip_distance', fare_calculation.distance_km, ...
                'location', obj.gps_tracker.current_location, ...
                'bus_state', obj.bus_state ...
            );
            
            obj.transaction_log{end+1} = transaction;
            
            % Remove passenger from active list
            obj.active_passengers.remove(passenger_id);
        end
        
        function start_trip_tracking(obj)
            % Start GPS tracking for trip
            obj.trip_tracking.active_trip = true;
            obj.trip_tracking.trip_start_time = datetime('now');
            obj.gps_tracker.trip_start_location = obj.gps_tracker.current_location;
            obj.update_bus_state('TRIP_ACTIVE');
        end
        
        function update_bus_state(obj, new_state)
            % Update bus state machine
            valid_states = {'IDLE', 'DOOR_DETECTED', 'IN_CABIN', 'TRIP_ACTIVE', 'NEAR_EXIT', 'EXIT_CONFIRMED'};
            
            if ismember(new_state, valid_states)
                obj.bus_state = new_state;
            end
        end
        
        function stats = get_system_statistics(obj)
            % Get comprehensive system statistics
            
            total_transactions = length(obj.transaction_log);
            boarding_count = sum(cellfun(@(x) strcmp(x.type, 'boarding'), obj.transaction_log));
            alighting_count = sum(cellfun(@(x) strcmp(x.type, 'alighting'), obj.transaction_log));
            
            if boarding_count > 0
                boarding_amounts = cellfun(@(x) x.amount, ...
                    obj.transaction_log(cellfun(@(x) strcmp(x.type, 'boarding'), obj.transaction_log)));
                avg_boarding_fare = mean(boarding_amounts);
                total_revenue = sum(boarding_amounts);
            else
                avg_boarding_fare = 0;
                total_revenue = 0;
            end
            
            stats = struct(...
                'total_transactions', total_transactions, ...
                'boarding_count', boarding_count, ...
                'alighting_count', alighting_count, ...
                'avg_boarding_fare', avg_boarding_fare, ...
                'total_revenue', total_revenue, ...
                'active_passengers', obj.active_passengers.Count, ...
                'current_state', obj.bus_state, ...
                'boarding_success_rate', obj.boarding_stats.successful_boardings / max(1, obj.boarding_stats.total_boardings) * 100, ...
                'alighting_success_rate', obj.alighting_stats.successful_alightings / max(1, obj.alighting_stats.total_alightings) * 100 ...
            );
        end
    end
end
