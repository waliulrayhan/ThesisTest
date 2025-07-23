% =========================================================================
% RUN THESIS - COMPLETE INTEGRATION
% Ultra-Wideband (UWB) Fare Collection for Public Transport
% Main execution script with all modules integrated
% =========================================================================

function run_thesis()
    clear all; close all; clc;
    
    fprintf('🎓 UWB THESIS SIMULATION - COMPLETE VERSION\n');
    fprintf('===================================================\n\n');
    
    try
        % Initialize Master Controller
        fprintf('🚀 Initializing Master Controller...\n');
        controller = EnhancedMasterController();
        
        % Run Complete Simulation
        fprintf('⚡ Running complete simulation...\n');
        results = controller.run_complete_simulation(1000, 8);
        
        % Generate Visualizations
        fprintf('📊 Creating visualizations...\n');
        controller.create_all_enhanced_visualizations();
        
        % Generate Reports
        fprintf('📋 Generating reports...\n');
        controller.generate_enhanced_thesis_report();
        
        % Run Additional Analysis
        fprintf('🔬 Running additional analysis...\n');
        controller.run_enhanced_analysis();
        
        fprintf('\n🎉 THESIS SIMULATION COMPLETED SUCCESSFULLY!\n');
        
    catch main_error
        fprintf('❌ MULATION ERROR: %s\n', main_error.message);
        fprintf('📍 Falling back to original simulation...\n');
        
        % Fallback to original simulation
        try
            run_original_thesis_simulation();
        catch fallback_error
            fprintf('❌ Original simulation also failed: %s\n', fallback_error.message);
            run_individual_module_tests();
        end
    end
end

% Fallback function to run original thesis simulation
function run_original_thesis_simulation()
    fprintf('🔄 Running original thesis simulation as fallback...\n');
    
    try
        % Try to run your original MasterSimulationController
        controller = MasterSimulationController();
        results = controller.run_complete_simulation(1000, 8);
        controller.generate_thesis_presentation_summary();
        fprintf('✅ Original simulation completed successfully!\n');
    catch original_error
        fprintf('❌ Original simulation failed: %s\n', original_error.message);
    end
end

% Individual module testing function
function run_individual_module_tests()
    fprintf('\n🧪 RUNNING INDIVIDUAL MODULE TESTS:\n');
    fprintf('===================================\n');
    
    % Test UWB Core Engine
    try
        fprintf('Testing UWB Core Engine...\n');
        anchors = [0,0; 15,0; 15,10; 0,10; 7.5,5];
        true_pos = [5, 3];
        [est_pos, error, quality] = uwb_core_engine(true_pos, anchors, 0.05, 0.02);
        fprintf('✅ UWB Core Engine: PASSED (Error: %.2fcm)\n', error*100);
    catch
        fprintf('❌ UWB Core Engine: FAILED\n');
    end
    
    % Test MultiModalTransport
    try
        fprintf('Testing MultiModalTransport...\n');
        transport = MultiModalTransport();
        stats = transport.get_network_statistics();
        fprintf('✅ MultiModalTransport: PASSED (%d locations)\n', stats.overall.total_anchor_points);
    catch
        fprintf('❌ MultiModalTransport: FAILED\n');
    end
    
    % Test UWBSecurityProtocol
    try
        fprintf('Testing UWBSecurityProtocol...\n');
        security = UWBSecurityProtocol();
        security.generate_authentication_token(1001);
        fprintf('✅ UWBSecurityProtocol: PASSED\n');
    catch
        fprintf('❌ UWBSecurityProtocol: FAILED\n');
    end
    
    % Test TechnologyComparator
    try
        fprintf('Testing TechnologyComparator...\n');
        comparator = TechnologyComparator();
        scores = comparator.calculate_technology_scores();
        fprintf('✅ TechnologyComparator: PASSED\n');
    catch
        fprintf('❌ TechnologyComparator: FAILED\n');
    end
    
    % Test EconomicFeasibilityCalculator
    try
        fprintf('Testing EconomicFeasibilityCalculator...\n');
        calculator = EconomicFeasibilityCalculator();
        analysis = calculator.calculate_deployment_economics('metro_pilot');
        fprintf('✅ EconomicFeasibilityCalculator: PASSED\n');
    catch
        fprintf('❌ EconomicFeasibilityCalculator: FAILED\n');
    end
    
    fprintf('\nIndividual module testing completed.\n');
end

% Helper function
function result = iif(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end