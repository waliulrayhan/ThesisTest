% =========================================================================
% Dual Gate Metro System Simulation
% UWB-based Entry/Exit Control with Zone Detection
% Implements real metro dual-gate mechanism with payment integration
% =========================================================================

classdef DualGateMetroSystem < handle
    properties
        % Gate configuration
        entry_gates
        exit_gates
        
        % UWB anchor configurations
        zone1_anchors_entry
        zone2_anchors_entry
        zone1_anchors_exit
        zone2_anchors_exit
        
        % Passenger tracking
        active_passengers
        transaction_log
        payment_system
        
        % System statistics
        entry_stats
        exit_stats
        security_events
        
        % Configuration parameters
        fare_rates
        detection_threshold
        transaction_timeout
    end
    
    methods
        function obj = DualGateMetroSystem()
            obj.initialize_gate_system();
            obj.setup_uwb_anchors();
            obj.initialize_payment_system();
            obj.setup_monitoring_systems();
            
            fprintf('🚇 Dual Gate Metro System initialized\n');
            fprintf('   Entry Gates: %d | Exit Gates: %d\n', ...
                    length(obj.entry_gates), length(obj.exit_gates));
        end
        
        function initialize_gate_system(obj)
            % Initialize dual gate configuration for metro station
            
            % Entry gate configuration (4 gates typical for metro station)
            obj.entry_gates = struct();
            for gate_id = 1:4
                obj.entry_gates.(sprintf('gate_%d', gate_id)) = struct(...
                    'gate_id', gate_id, ...
                    'status', 'closed', ...
                    'zone1_detection', false, ...
                    'zone2_detection', false, ...
                    'current_passenger', [], ...
                    'transaction_start_time', [], ...
                    'gate_type', 'entry' ...
                );
            end
            
            % Exit gate configuration (4 gates for exit)
            obj.exit_gates = struct();
            for gate_id = 1:4
                obj.exit_gates.(sprintf('gate_%d', gate_id)) = struct(...
                    'gate_id', gate_id, ...
                    'status', 'closed', ...
                    'zone1_detection', false, ...
                    'zone2_detection', false, ...
                    'current_passenger', [], ...
                    'transaction_start_time', [], ...
                    'gate_type', 'exit' ...
                );
            end
        end
        
        function setup_uwb_anchors(obj)
            % Setup UWB anchors for each zone in entry and exit areas
            
            % Entry area - Zone 1 anchors (before gate) - Anchors A1-A4
            obj.zone1_anchors_entry = [
                0, 0;      % Anchor A1 - Corner
                3, 0;      % Anchor A2 - Opposite corner
                0, 2;      % Anchor A3 - Back corner
                3, 2       % Anchor A4 - Far corner
            ];
            
            % Entry area - Zone 2 anchors (after gate) - Anchors A5-A8
            obj.zone2_anchors_entry = [
                4, 0;      % Anchor A5 - Gate exit side
                7, 0;      % Anchor A6 - Far side
                4, 2;      % Anchor A7 - Back of zone 2
                7, 2       % Anchor A8 - Far back corner
            ];
            
            % Exit area - Zone 1 anchors (platform side) - Anchors A9-A12
            obj.zone1_anchors_exit = [
                10, 0;     % Anchor A9 - Platform corner
                13, 0;     % Anchor A10 - Platform far
                10, 2;     % Anchor A11 - Platform back
                13, 2      % Anchor A12 - Platform far back
            ];
            
            % Exit area - Zone 2 anchors (after exit gate) - Anchors A13-A16
            obj.zone2_anchors_exit = [
                14, 0;     % Anchor A13 - Exit area
                17, 0;     % Anchor A14 - Exit far
                14, 2;     % Anchor A15 - Exit back
                17, 2      % Anchor A16 - Exit far back
            ];
            
            % Detection parameters
            obj.detection_threshold = 0.05; % 5cm accuracy threshold
            obj.transaction_timeout = 30;   % 30 seconds maximum transaction time
        end
        
        function initialize_payment_system(obj)
            % Initialize integrated payment system
            
            obj.payment_system = struct();
            obj.fare_rates = struct(...
                'base_fare', 20, ...        % 20 BDT base fare
                'distance_rate', 2, ...     % 2 BDT per km
                'peak_multiplier', 1.5, ... % 50% peak hour surcharge
                'student_discount', 0.5, ...% 50% student discount
                'senior_discount', 0.3 ...  % 30% senior discount
            );
            
            obj.active_passengers = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            obj.transaction_log = [];
        end
        
        function setup_monitoring_systems(obj)
            % Initialize monitoring and statistics systems
            
            obj.entry_stats = struct(...
                'total_entries', 0, ...
                'successful_entries', 0, ...
                'failed_entries', 0, ...
                'unauthorized_attempts', 0, ...
                'average_entry_time', 0 ...
            );
            
            obj.exit_stats = struct(...
                'total_exits', 0, ...
                'successful_exits', 0, ...
                'failed_exits', 0, ...
                'fare_evasion_attempts', 0, ...
                'average_exit_time', 0 ...
            );
            
            obj.security_events = [];
        end
        
        function result = simulate_passenger_entry(obj, passenger_id, uwb_device_info, payment_method)
            % Simulate complete passenger entry process through dual gates
            
            fprintf('\n🚶 Passenger %d attempting entry...\n', passenger_id);
            
            result = struct();
            result.passenger_id = passenger_id;
            result.entry_time = now;
            result.success = false;
            result.failure_reason = '';
            result.transaction_details = struct();
            
            % Step 1: Select available entry gate
            available_gate = obj.find_available_gate('entry');
            if isempty(available_gate)
                result.failure_reason = 'No available gates';
                fprintf('   ❌ Entry failed: No available gates\n');
                obj.entry_stats.failed_entries = obj.entry_stats.failed_entries + 1;
                return;
            end
            
            fprintf('   🚪 Using entry gate %d\n', available_gate);
            
            % Step 2: Zone 1 Detection (Before Gate)
            zone1_result = obj.detect_passenger_in_zone(passenger_id, uwb_device_info, ...
                obj.zone1_anchors_entry, 'entry_zone1');
            
            if ~zone1_result.detected
                result.failure_reason = 'Zone 1 detection failed - No UWB device';
                fprintf('   ❌ Zone 1 detection failed: %s\n', zone1_result.error_message);
                obj.log_security_event(passenger_id, 'ENTRY_ZONE1_DETECTION_FAILED', available_gate);
                obj.entry_stats.unauthorized_attempts = obj.entry_stats.unauthorized_attempts + 1;
                return;
            end
            
            fprintf('   ✅ Zone 1 detection successful (Accuracy: %.2fcm)\n', zone1_result.accuracy_cm);
            
            % Step 3: Payment Authorization
            payment_result = obj.process_payment_authorization(passenger_id, payment_method, 'entry');
            
            if ~payment_result.authorized
                result.failure_reason = sprintf('Payment authorization failed: %s', payment_result.error_message);
                fprintf('   ❌ Payment failed: %s\n', payment_result.error_message);
                obj.entry_stats.failed_entries = obj.entry_stats.failed_entries + 1;
                return;
            end
            
            fprintf('   💳 Payment authorized: %.2f BDT\n', payment_result.fare_amount);
            
            % Step 4: Open Gate and Monitor Zone 2
            obj.open_gate(available_gate, 'entry');
            fprintf('   🔓 Gate %d opened\n', available_gate);
            
            % Step 5: Zone 2 Detection (After Gate)
            zone2_result = obj.detect_passenger_in_zone(passenger_id, uwb_device_info, ...
                obj.zone2_anchors_entry, 'entry_zone2');
            
            if ~zone2_result.detected
                result.failure_reason = 'Zone 2 detection failed';
                fprintf('   ❌ Zone 2 detection failed\n');
                obj.close_gate(available_gate, 'entry');
                obj.log_security_event(passenger_id, 'ENTRY_ZONE2_DETECTION_FAILED', available_gate);
                return;
            end
            
            fprintf('   ✅ Zone 2 detection successful (Accuracy: %.2fcm)\n', zone2_result.accuracy_cm);
            
            % Step 6: Complete Entry Transaction
            obj.complete_entry_transaction(passenger_id, available_gate, payment_result);
            obj.close_gate(available_gate, 'entry');
            
            % Update passenger status
            passenger_data = struct(...
                'passenger_id', passenger_id, ...
                'entry_time', now, ...
                'entry_gate', available_gate, ...
                'fare_paid', payment_result.fare_amount, ...
                'entry_zone1_accuracy', zone1_result.accuracy_cm, ...
                'entry_zone2_accuracy', zone2_result.accuracy_cm, ...
                'status', 'inside_station' ...
            );
            
            obj.active_passengers(passenger_id) = passenger_data;
            
            result.success = true;
            result.transaction_details = payment_result;
            result.gate_used = available_gate;
            result.total_time = (now - result.entry_time) * 24 * 3600; % seconds
            
            obj.entry_stats.total_entries = obj.entry_stats.total_entries + 1;
            obj.entry_stats.successful_entries = obj.entry_stats.successful_entries + 1;
            
            fprintf('   🎉 Entry completed successfully in %.2f seconds\n', result.total_time);
        end
        
        function result = simulate_passenger_exit(obj, passenger_id, uwb_device_info)
            % Simulate complete passenger exit process through dual gates
            
            fprintf('\n🚶 Passenger %d attempting exit...\n', passenger_id);
            
            result = struct();
            result.passenger_id = passenger_id;
            result.exit_time = now;
            result.success = false;
            result.failure_reason = '';
            result.fare_calculation = struct();
            
            % Step 1: Verify passenger is in system
            if ~obj.active_passengers.isKey(passenger_id)
                result.failure_reason = 'Passenger not found in system';
                fprintf('   ❌ Exit failed: Passenger not in system\n');
                obj.exit_stats.fare_evasion_attempts = obj.exit_stats.fare_evasion_attempts + 1;
                return;
            end
            
            passenger_data = obj.active_passengers(passenger_id);
            
            % Step 2: Select available exit gate
            available_gate = obj.find_available_gate('exit');
            if isempty(available_gate)
                result.failure_reason = 'No available exit gates';
                fprintf('   ❌ Exit failed: No available gates\n');
                obj.exit_stats.failed_exits = obj.exit_stats.failed_exits + 1;
                return;
            end
            
            fprintf('   🚪 Using exit gate %d\n', available_gate);
            
            % Step 3: Zone 1 Detection (Platform Side)
            zone1_result = obj.detect_passenger_in_zone(passenger_id, uwb_device_info, ...
                obj.zone1_anchors_exit, 'exit_zone1');
            
            if ~zone1_result.detected
                result.failure_reason = 'Exit Zone 1 detection failed';
                fprintf('   ❌ Exit Zone 1 detection failed\n');
                obj.log_security_event(passenger_id, 'EXIT_ZONE1_DETECTION_FAILED', available_gate);
                obj.exit_stats.failed_exits = obj.exit_stats.failed_exits + 1;
                return;
            end
            
            fprintf('   ✅ Exit Zone 1 detection successful (Accuracy: %.2fcm)\n', zone1_result.accuracy_cm);
            
            % Step 4: Calculate Final Fare (if distance-based)
            fare_calculation = obj.calculate_final_fare(passenger_data);
            fprintf('   💰 Final fare calculated: %.2f BDT\n', fare_calculation.total_fare);
            
            % Step 5: Process Additional Payment (if needed)
            if fare_calculation.additional_payment > 0
                additional_payment = obj.process_additional_payment(passenger_id, fare_calculation.additional_payment);
                if ~additional_payment.success
                    result.failure_reason = 'Additional payment failed';
                    fprintf('   ❌ Additional payment failed: %.2f BDT required\n', fare_calculation.additional_payment);
                    obj.exit_stats.failed_exits = obj.exit_stats.failed_exits + 1;
                    return;
                end
                fprintf('   💳 Additional payment processed: %.2f BDT\n', fare_calculation.additional_payment);
            end
            
            % Step 6: Open Exit Gate
            obj.open_gate(available_gate, 'exit');
            fprintf('   🔓 Exit gate %d opened\n', available_gate);
            
            % Step 7: Zone 2 Detection (After Exit Gate)
            zone2_result = obj.detect_passenger_in_zone(passenger_id, uwb_device_info, ...
                obj.zone2_anchors_exit, 'exit_zone2');
            
            if ~zone2_result.detected
                result.failure_reason = 'Exit Zone 2 detection failed';
                fprintf('   ❌ Exit Zone 2 detection failed\n');
                obj.close_gate(available_gate, 'exit');
                obj.log_security_event(passenger_id, 'EXIT_ZONE2_DETECTION_FAILED', available_gate);
                return;
            end
            
            fprintf('   ✅ Exit Zone 2 detection successful (Accuracy: %.2fcm)\n', zone2_result.accuracy_cm);
            
            % Step 8: Complete Exit Transaction
            obj.complete_exit_transaction(passenger_id, available_gate, fare_calculation);
            obj.close_gate(available_gate, 'exit');
            
            % Remove passenger from active system
            obj.active_passengers.remove(passenger_id);
            
            result.success = true;
            result.fare_calculation = fare_calculation;
            result.gate_used = available_gate;
            result.total_time = (now - result.exit_time) * 24 * 3600; % seconds
            
            obj.exit_stats.total_exits = obj.exit_stats.total_exits + 1;
            obj.exit_stats.successful_exits = obj.exit_stats.successful_exits + 1;
            
            fprintf('   🎉 Exit completed successfully in %.2f seconds\n', result.total_time);
        end
        
        function zone_result = detect_passenger_in_zone(obj, passenger_id, uwb_device_info, zone_anchors, zone_name)
            % Detect passenger presence in specific zone using UWB anchors
            
            zone_result = struct();
            zone_result.detected = false;
            zone_result.accuracy_cm = inf;
            zone_result.position = [0, 0];
            zone_result.error_message = '';
            
            % Check if passenger has valid UWB device
            if isempty(uwb_device_info) || ~uwb_device_info.active
                zone_result.error_message = 'No active UWB device';
                return;
            end
            
            % Simulate passenger position in zone
            if strcmp(zone_name, 'entry_zone1')
                true_position = [1.5, 1]; % Center of entry zone 1
            elseif strcmp(zone_name, 'entry_zone2')
                true_position = [5.5, 1]; % Center of entry zone 2
            elseif strcmp(zone_name, 'exit_zone1')
                true_position = [11.5, 1]; % Center of exit zone 1
            elseif strcmp(zone_name, 'exit_zone2')
                true_position = [15.5, 1]; % Center of exit zone 2
            else
                zone_result.error_message = 'Unknown zone';
                return;
            end
            
            % Add some randomness to simulate real movement
            true_position = true_position + normrnd(0, 0.3, [1, 2]);
            
            try
                % Use UWB core engine for precise localization
                [estimated_pos, localization_error, signal_quality] = uwb_core_engine(...
                    true_position, zone_anchors, 0.01, 0.005);
                
                zone_result.detected = true;
                zone_result.accuracy_cm = localization_error * 100;
                zone_result.position = estimated_pos;
                zone_result.signal_quality = signal_quality;
                
            catch uwb_error
                zone_result.error_message = sprintf('UWB detection error: %s', uwb_error.message);
            end
        end
        
        function payment_result = process_payment_authorization(obj, passenger_id, payment_method, transaction_type)
            % Process payment authorization for entry
            
            payment_result = struct();
            payment_result.authorized = false;
            payment_result.fare_amount = 0;
            payment_result.error_message = '';
            payment_result.transaction_id = sprintf('TXN_%d_%s', passenger_id, datestr(now, 'yyyymmddHHMMSS'));
            
            % Calculate base fare
            base_fare = obj.fare_rates.base_fare;
            
            % Apply time-based multipliers (peak hours)
            current_hour = hour(datetime('now'));
            if (current_hour >= 7 && current_hour <= 9) || (current_hour >= 17 && current_hour <= 19)
                base_fare = base_fare * obj.fare_rates.peak_multiplier;
            end
            
            % Apply discounts based on payment method
            if isfield(payment_method, 'passenger_type')
                switch payment_method.passenger_type
                    case 'student'
                        base_fare = base_fare * (1 - obj.fare_rates.student_discount);
                    case 'senior'
                        base_fare = base_fare * (1 - obj.fare_rates.senior_discount);
                end
            end
            
            payment_result.fare_amount = base_fare;
            
            % Simulate payment processing
            if isfield(payment_method, 'balance') && payment_method.balance >= base_fare
                payment_result.authorized = true;
                payment_result.remaining_balance = payment_method.balance - base_fare;
            elseif strcmp(payment_method.type, 'credit_card')
                % Simulate credit card authorization (90% success rate)
                if rand() > 0.1
                    payment_result.authorized = true;
                else
                    payment_result.error_message = 'Credit card declined';
                end
            else
                payment_result.error_message = 'Insufficient balance';
            end
        end
        
        function fare_calc = calculate_final_fare(obj, passenger_data)
            % Calculate final fare based on journey distance and time
            
            fare_calc = struct();
            
            % Calculate journey time
            journey_time_hours = (now - passenger_data.entry_time) * 24;
            
            % Base calculation
            fare_calc.base_fare = passenger_data.fare_paid;
            fare_calc.journey_time_hours = journey_time_hours;
            
            % Distance-based calculation (simulated)
            estimated_distance_km = max(1, normrnd(5, 2)); % 5km average with variation
            fare_calc.distance_km = estimated_distance_km;
            fare_calc.distance_fare = estimated_distance_km * obj.fare_rates.distance_rate;
            
            % Total fare calculation
            fare_calc.total_fare = fare_calc.base_fare + fare_calc.distance_fare;
            
            % Additional payment needed
            fare_calc.additional_payment = max(0, fare_calc.total_fare - fare_calc.base_fare);
            
            % Apply any time penalties (if journey is too long - potential fraud)
            if journey_time_hours > 3 % 3 hours maximum
                fare_calc.penalty = fare_calc.base_fare * 0.5; % 50% penalty
                fare_calc.total_fare = fare_calc.total_fare + fare_calc.penalty;
                fare_calc.additional_payment = fare_calc.additional_payment + fare_calc.penalty;
            else
                fare_calc.penalty = 0;
            end
        end
        
        function payment_result = process_additional_payment(obj, passenger_id, amount)
            % Process additional payment at exit if needed
            
            payment_result = struct();
            payment_result.success = true; % Simplified - assume payment succeeds
            payment_result.amount = amount;
            payment_result.transaction_id = sprintf('EXIT_TXN_%d_%s', passenger_id, datestr(now, 'yyyymmddHHMMSS'));
        end
        
        function gate_id = find_available_gate(obj, gate_type)
            % Find available gate for passenger
            
            if strcmp(gate_type, 'entry')
                gates = obj.entry_gates;
            else
                gates = obj.exit_gates;
            end
            
            gate_names = fieldnames(gates);
            for i = 1:length(gate_names)
                gate_name = gate_names{i};
                if strcmp(gates.(gate_name).status, 'closed') && isempty(gates.(gate_name).current_passenger)
                    gate_id = gates.(gate_name).gate_id;
                    return;
                end
            end
            
            gate_id = []; % No available gates
        end
        
        function open_gate(obj, gate_id, gate_type)
            % Open specified gate
            gate_field = sprintf('gate_%d', gate_id);
            
            if strcmp(gate_type, 'entry')
                obj.entry_gates.(gate_field).status = 'open';
                obj.entry_gates.(gate_field).transaction_start_time = now;
            else
                obj.exit_gates.(gate_field).status = 'open';
                obj.exit_gates.(gate_field).transaction_start_time = now;
            end
        end
        
        function close_gate(obj, gate_id, gate_type)
            % Close specified gate
            gate_field = sprintf('gate_%d', gate_id);
            
            if strcmp(gate_type, 'entry')
                obj.entry_gates.(gate_field).status = 'closed';
                obj.entry_gates.(gate_field).current_passenger = [];
                obj.entry_gates.(gate_field).transaction_start_time = [];
            else
                obj.exit_gates.(gate_field).status = 'closed';
                obj.exit_gates.(gate_field).current_passenger = [];
                obj.exit_gates.(gate_field).transaction_start_time = [];
            end
        end
        
        function complete_entry_transaction(obj, passenger_id, gate_id, payment_result)
            % Complete entry transaction logging
            
            transaction = struct(...
                'timestamp', now, ...
                'passenger_id', passenger_id, ...
                'transaction_type', 'entry', ...
                'gate_id', gate_id, ...
                'fare_amount', payment_result.fare_amount, ...
                'total_fare', payment_result.fare_amount, ...
                'additional_payment', 0, ...
                'journey_distance', 0, ...
                'journey_time', 0, ...
                'transaction_id', payment_result.transaction_id, ...
                'status', 'completed' ...
            );
            
            obj.transaction_log = [obj.transaction_log; transaction];
        end
        
        function complete_exit_transaction(obj, passenger_id, gate_id, fare_calculation)
            % Complete exit transaction logging
            
            transaction = struct(...
                'timestamp', now, ...
                'passenger_id', passenger_id, ...
                'transaction_type', 'exit', ...
                'gate_id', gate_id, ...
                'fare_amount', fare_calculation.total_fare, ...
                'total_fare', fare_calculation.total_fare, ...
                'additional_payment', fare_calculation.additional_payment, ...
                'journey_distance', fare_calculation.distance_km, ...
                'journey_time', fare_calculation.journey_time_hours, ...
                'transaction_id', sprintf('EXIT_%d_%s', passenger_id, datestr(now, 'yyyymmddHHMMSS')), ...
                'status', 'completed' ...
            );
            
            obj.transaction_log = [obj.transaction_log; transaction];
        end
        
        function log_security_event(obj, passenger_id, event_type, gate_id)
            % Log security events
            
            security_event = struct(...
                'timestamp', now, ...
                'passenger_id', passenger_id, ...
                'event_type', event_type, ...
                'gate_id', gate_id, ...
                'severity', 'medium' ...
            );
            
            obj.security_events = [obj.security_events; security_event];
        end
        
        function stats = get_system_statistics(obj)
            % Get comprehensive system statistics
            
            stats = struct();
            
            % Entry statistics
            stats.entry = obj.entry_stats;
            if obj.entry_stats.total_entries > 0
                stats.entry.success_rate = (obj.entry_stats.successful_entries / obj.entry_stats.total_entries) * 100;
            else
                stats.entry.success_rate = 0;
            end
            
            % Exit statistics
            stats.exit = obj.exit_stats;
            if obj.exit_stats.total_exits > 0
                stats.exit.success_rate = (obj.exit_stats.successful_exits / obj.exit_stats.total_exits) * 100;
            else
                stats.exit.success_rate = 0;
            end
            
            % Overall statistics
            stats.overall = struct();
            stats.overall.total_transactions = obj.entry_stats.total_entries + obj.exit_stats.total_exits;
            stats.overall.active_passengers = obj.active_passengers.Count;
            stats.overall.security_events = length(obj.security_events);
            stats.overall.total_revenue = obj.calculate_total_revenue();
        end
        
        function revenue = calculate_total_revenue(obj)
            % Calculate total revenue from transactions
            
            revenue = 0;
            for i = 1:length(obj.transaction_log)
                if strcmp(obj.transaction_log(i).transaction_type, 'entry')
                    revenue = revenue + obj.transaction_log(i).fare_amount;
                elseif strcmp(obj.transaction_log(i).transaction_type, 'exit')
                    revenue = revenue + obj.transaction_log(i).additional_payment;
                end
            end
        end
        
        function simulate_rush_hour_scenario(obj, num_passengers, duration_minutes)
            % Simulate rush hour with multiple passengers
            
            fprintf('\n🚇 SIMULATING RUSH HOUR SCENARIO\n');
            fprintf('================================================\n');
            fprintf('Passengers: %d | Duration: %d minutes\n\n', num_passengers, duration_minutes);
            
            % Generate passenger data
            passengers = obj.generate_passenger_data(num_passengers);
            
            % Simulate entries
            fprintf('📥 ENTRY PHASE\n');
            fprintf('===============\n');
            
            for i = 1:num_passengers
                passenger = passengers(i);
                
                % Simulate entry
                entry_result = obj.simulate_passenger_entry(passenger.id, passenger.uwb_device, passenger.payment_method);
                
                % Add small delay between passengers
                pause(0.1);
                
                if mod(i, 10) == 0
                    fprintf('   Progress: %d/%d passengers processed\n', i, num_passengers);
                end
            end
            
            % Wait some time (simulate journey)
            fprintf('\n⏱️ JOURNEY PHASE (simulating %d minutes)\n', duration_minutes);
            fprintf('=======================================\n');
            pause(1); % Simulate journey time (compressed)
            
            % Simulate exits
            fprintf('\n📤 EXIT PHASE\n');
            fprintf('==============\n');
            
            active_passenger_ids = keys(obj.active_passengers);
            for i = 1:length(active_passenger_ids)
                passenger_id = active_passenger_ids{i};
                passenger_data = obj.active_passengers(passenger_id);
                
                % Find original passenger UWB device info
                original_passenger = passengers([passengers.id] == passenger_id);
                
                % Simulate exit
                exit_result = obj.simulate_passenger_exit(passenger_id, original_passenger.uwb_device);
                
                % Add small delay between passengers
                pause(0.1);
                
                if mod(i, 10) == 0
                    fprintf('   Progress: %d/%d passengers exited\n', i, length(active_passenger_ids));
                end
            end
            
            % Display final statistics
            fprintf('\n📊 RUSH HOUR SIMULATION COMPLETED\n');
            fprintf('==================================\n');
            obj.display_system_statistics();
        end
        
        function passengers = generate_passenger_data(obj, num_passengers)
            % Generate realistic passenger data for simulation
            
            passengers = [];
            
            for i = 1:num_passengers
                passenger = struct();
                passenger.id = 1000 + i;
                
                % UWB device info (95% have devices)
                if rand() > 0.05
                    passenger.uwb_device = struct(...
                        'active', true, ...
                        'device_id', sprintf('UWB_%06d', passenger.id), ...
                        'signal_strength', 85 + randn() * 5 ...
                    );
                else
                    passenger.uwb_device = struct('active', false);
                end
                
                % Payment method
                payment_types = {'prepaid_card', 'credit_card', 'mobile_wallet'};
                passenger_types = {'regular', 'student', 'senior'};
                
                passenger.payment_method = struct(...
                    'type', payment_types{randi(length(payment_types))}, ...
                    'balance', 100 + rand() * 200, ... % Random balance 100-300 BDT
                    'passenger_type', passenger_types{randi(length(passenger_types))} ...
                );
                
                passengers = [passengers; passenger];
            end
        end
        
        function display_system_statistics(obj)
            % Display comprehensive system statistics
            
            stats = obj.get_system_statistics();
            
            fprintf('\n📈 SYSTEM PERFORMANCE STATISTICS\n');
            fprintf('=================================\n');
            
            fprintf('ENTRY STATISTICS:\n');
            fprintf('  Total Attempts:      %d\n', stats.entry.total_entries);
            fprintf('  Successful Entries:  %d\n', stats.entry.successful_entries);
            fprintf('  Failed Entries:      %d\n', stats.entry.failed_entries);
            fprintf('  Success Rate:        %.1f%%\n', stats.entry.success_rate);
            fprintf('  Unauthorized:        %d\n', stats.entry.unauthorized_attempts);
            
            fprintf('\nEXIT STATISTICS:\n');
            fprintf('  Total Attempts:      %d\n', stats.exit.total_exits);
            fprintf('  Successful Exits:    %d\n', stats.exit.successful_exits);
            fprintf('  Failed Exits:        %d\n', stats.exit.failed_exits);
            fprintf('  Success Rate:        %.1f%%\n', stats.exit.success_rate);
            fprintf('  Evasion Attempts:    %d\n', stats.exit.fare_evasion_attempts);
            
            fprintf('\nOVERALL STATISTICS:\n');
            fprintf('  Total Transactions:  %d\n', stats.overall.total_transactions);
            fprintf('  Active Passengers:   %d\n', stats.overall.active_passengers);
            fprintf('  Security Events:     %d\n', stats.overall.security_events);
            fprintf('  Total Revenue:       %.2f BDT\n', stats.overall.total_revenue);
            
            % Calculate system efficiency metrics
            if stats.overall.total_transactions > 0
                overall_success_rate = ((stats.entry.successful_entries + stats.exit.successful_exits) / stats.overall.total_transactions) * 100;
                fprintf('  System Success Rate: %.1f%%\n', overall_success_rate);
            end
        end
        
        function visualize_gate_layout(obj)
            % Visualize the dual gate system layout
            
            figure('Name', 'Dual Gate Metro System Layout', 'Position', [100, 100, 1200, 600]);
            
            % Plot entry area
            subplot(1, 2, 1);
            hold on;
            
            % Draw zones
            rectangle('Position', [0, 0, 3, 2], 'FaceColor', [1, 1, 0, 0.3], 'EdgeColor', 'k', 'LineWidth', 2);
            text(1.5, 1, 'Entry Zone 1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            
            rectangle('Position', [4, 0, 3, 2], 'FaceColor', [0, 1, 0, 0.3], 'EdgeColor', 'k', 'LineWidth', 2);
            text(5.5, 1, 'Entry Zone 2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            
            % Draw gate
            plot([3.5, 3.5], [0, 2], 'r-', 'LineWidth', 4);
            text(3.5, 2.2, 'Gate', 'HorizontalAlignment', 'center', 'Color', 'red', 'FontWeight', 'bold');
            
            % Plot UWB anchors
            plot(obj.zone1_anchors_entry(:,1), obj.zone1_anchors_entry(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
            plot(obj.zone2_anchors_entry(:,1), obj.zone2_anchors_entry(:,2), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'green');
            
            % Labels
            for i = 1:size(obj.zone1_anchors_entry, 1)
                text(obj.zone1_anchors_entry(i,1), obj.zone1_anchors_entry(i,2) + 0.1, sprintf('A%d', i), ...
                     'HorizontalAlignment', 'center', 'Color', 'blue', 'FontSize', 8);
            end
            
            for i = 1:size(obj.zone2_anchors_entry, 1)
                text(obj.zone2_anchors_entry(i,1), obj.zone2_anchors_entry(i,2) + 0.1, sprintf('A%d', i+4), ...
                     'HorizontalAlignment', 'center', 'Color', 'green', 'FontSize', 8);
            end
            
            title('Entry Gate System');
            xlabel('Distance (m)');
            ylabel('Distance (m)');
            axis equal;
            grid on;
            legend('Zone 1 Anchors', 'Zone 2 Anchors', 'Location', 'best');
            
            % Plot exit area
            subplot(1, 2, 2);
            hold on;
            
            % Draw zones
            rectangle('Position', [10, 0, 3, 2], 'FaceColor', [0, 1, 1, 0.3], 'EdgeColor', 'k', 'LineWidth', 2);
            text(11.5, 1, 'Exit Zone 1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            
            rectangle('Position', [14, 0, 3, 2], 'FaceColor', [1, 0, 1, 0.3], 'EdgeColor', 'k', 'LineWidth', 2);
            text(15.5, 1, 'Exit Zone 2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            
            % Draw gate
            plot([13.5, 13.5], [0, 2], 'r-', 'LineWidth', 4);
            text(13.5, 2.2, 'Gate', 'HorizontalAlignment', 'center', 'Color', 'red', 'FontWeight', 'bold');
            
            % Plot UWB anchors
            plot(obj.zone1_anchors_exit(:,1), obj.zone1_anchors_exit(:,2), 'co', 'MarkerSize', 8, 'MarkerFaceColor', 'cyan');
            plot(obj.zone2_anchors_exit(:,1), obj.zone2_anchors_exit(:,2), 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'magenta');
            
            % Labels
            for i = 1:size(obj.zone1_anchors_exit, 1)
                text(obj.zone1_anchors_exit(i,1), obj.zone1_anchors_exit(i,2) + 0.1, sprintf('A%d', i+8), ...
                     'HorizontalAlignment', 'center', 'Color', 'cyan', 'FontSize', 8);
            end
            
            for i = 1:size(obj.zone2_anchors_exit, 1)
                text(obj.zone2_anchors_exit(i,1), obj.zone2_anchors_exit(i,2) + 0.1, sprintf('A%d', i+12), ...
                     'HorizontalAlignment', 'center', 'Color', 'magenta', 'FontSize', 8);
            end
            
            title('Exit Gate System');
            xlabel('Distance (m)');
            ylabel('Distance (m)');
            axis equal;
            grid on;
            legend('Zone 1 Anchors', 'Zone 2 Anchors', 'Location', 'best');
            
            sgtitle('UWB Dual Gate Metro System Layout', 'FontSize', 16, 'FontWeight', 'bold');
        end
    end
end

% Test function
function test_dual_gate_metro_system()
    fprintf('🧪 TESTING DUAL GATE METRO SYSTEM\n');
    fprintf('===================================\n');
    
    % Initialize system
    metro_system = DualGateMetroSystem();
    
    % Visualize layout
    metro_system.visualize_gate_layout();
    
    % Test single passenger entry and exit
    fprintf('\n🧪 Testing single passenger transaction...\n');
    
    % Create test passenger
    test_passenger = struct();
    test_passenger.id = 1001;
    test_passenger.uwb_device = struct('active', true, 'device_id', 'UWB_001001', 'signal_strength', 90);
    test_passenger.payment_method = struct('type', 'prepaid_card', 'balance', 150, 'passenger_type', 'regular');
    
    % Test entry
    entry_result = metro_system.simulate_passenger_entry(test_passenger.id, test_passenger.uwb_device, test_passenger.payment_method);
    
    if entry_result.success
        % Test exit
        pause(1); % Simulate journey time
        exit_result = metro_system.simulate_passenger_exit(test_passenger.id, test_passenger.uwb_device);
    end
    
    % Display statistics
    metro_system.display_system_statistics();
    
    % Test rush hour scenario
    fprintf('\n🧪 Testing rush hour scenario...\n');
    metro_system.simulate_rush_hour_scenario(50, 30);
end
