% =========================================================================
% Module 5: Economic Feasibility Calculator
% Comprehensive economic analysis for UWB fare collection implementation
% =========================================================================

classdef EconomicFeasibilityCalculator < handle
    properties
        deployment_scenarios
        cost_models
        revenue_models
        financial_projections
        bangladesh_economic_data
    end
    
    methods
        function obj = EconomicFeasibilityCalculator()
            obj.initialize_bangladesh_economic_data();
            obj.setup_deployment_scenarios();
            obj.create_cost_models();
            obj.create_revenue_models();
        end
        
        function initialize_bangladesh_economic_data(obj)
            % Initialize Bangladesh-specific economic parameters
            
            obj.bangladesh_economic_data = struct(...
                'gdp_per_capita_usd', 2824, ... % 2024 data
                'inflation_rate', 0.09, ... % 9% annual inflation
                'interest_rate', 0.06, ... % 6% discount rate
                'exchange_rate_bdt_usd', 110, ... % 1 USD = 110 BDT (approximate)
                'metro_daily_ridership', 400000, ... % Current Dhaka Metro ridership
                'bus_daily_ridership', 3000000, ... % Estimated bus ridership
                'launch_daily_ridership', 50000, ... % River transport ridership
                'avg_metro_fare_bdt', 45, ... % Average metro fare
                'avg_bus_fare_bdt', 15, ... % Average bus fare
                'avg_launch_fare_bdt', 150, ... % Average launch fare
                'labor_cost_usd_per_hour', 1.5, ... % Technical labor cost
                'electricity_cost_usd_per_kwh', 0.08, ... % Industrial electricity rate
                'maintenance_cost_factor', 0.15 ... % 15% of equipment cost annually
            );
        end
        
        function setup_deployment_scenarios(obj)
            % Define different deployment scenarios for analysis
            
            obj.deployment_scenarios = struct();
            
            % Scenario 1: Metro-only pilot deployment
            obj.deployment_scenarios.metro_pilot = struct(...
                'name', 'Metro Pilot Deployment', ...
                'description', 'UWB deployment in 5 busiest metro stations', ...
                'stations_count', 5, ...
                'anchors_per_station', 8, ...
                'daily_users', 200000, ...
                'deployment_timeline_months', 6, ...
                'deployment_duration_years', 2 ... % Fixed: consistent field name
            );
            
            % Scenario 2: Full metro deployment
            obj.deployment_scenarios.metro_full = struct(...
                'name', 'Full Metro Network Deployment', ...
                'description', 'UWB deployment across all metro stations', ...
                'stations_count', 17, ... % Current + planned metro stations
                'anchors_per_station', 8, ...
                'daily_users', 800000, ... % Projected full ridership
                'deployment_timeline_months', 18, ...
                'deployment_duration_years', 10 ... % Fixed: consistent field name
            );
            
            % Scenario 3: Multi-modal deployment
            obj.deployment_scenarios.multi_modal = struct(...
                'name', 'Multi-Modal Transport Deployment', ...
                'description', 'UWB across metro, major bus routes, and launch terminals', ...
                'metro_stations', 17, ...
                'bus_stops', 50, ... % Major bus stops
                'launch_terminals', 10, ...
                'anchors_per_location', 6, ...
                'daily_users', 2000000, ... % Combined ridership
                'deployment_timeline_months', 36, ...
                'deployment_duration_years', 15 ... % Fixed: consistent field name
            );
            
            % Scenario 4: Nationwide rollout
            obj.deployment_scenarios.nationwide = struct(...
                'name', 'Nationwide Transport Digitization', ...
                'description', 'UWB deployment across major cities in Bangladesh', ...
                'total_locations', 500, ... % Stations/stops across major cities
                'anchors_per_location', 6, ...
                'daily_users', 5000000, ... % National public transport users
                'deployment_timeline_months', 60, ...
                'deployment_duration_years', 20 ... % Fixed: consistent field name
            );
        end
        
        function create_cost_models(obj)
            % Create detailed cost models for UWB deployment
            
            obj.cost_models = struct();
            
            % Hardware costs (optimized for mass production)
            obj.cost_models.hardware = struct(...
                'uwb_anchor_unit_cost_usd', 120, ... % Reduced cost due to economies of scale
                'uwb_mobile_tag_cost_usd', 18, ... % Reduced per passenger device/card cost
                'network_infrastructure_cost_usd', 40000, ... % Optimized central processing system
                'installation_cost_per_anchor_usd', 150, ... % Reduced installation labor with expertise
                'gateway_cost_per_station_usd', 1500 ... % Optimized network gateway per station
            );
            
            % Software and development costs
            obj.cost_models.software = struct(...
                'core_system_development_usd', 500000, ... % One-time development
                'mobile_app_development_usd', 100000, ... % User mobile app
                'integration_cost_usd', 200000, ... % Integration with existing systems
                'security_system_cost_usd', 150000, ... % Security protocol implementation
                'testing_validation_cost_usd', 100000 ... % System testing and validation
            );
            
            % Operational costs (annual)
            obj.cost_models.operational = struct(...
                'maintenance_cost_factor', 0.12, ... % 12% of hardware cost annually
                'software_maintenance_usd', 50000, ... % Annual software updates
                'technical_support_staff', 10, ... % Number of technical staff
                'customer_support_staff', 5, ... % Number of customer support staff
                'electricity_cost_per_anchor_kwh', 0.1, ... % kWh per anchor per year
                'data_processing_cost_usd', 25000, ... % Annual cloud/server costs
                'regulatory_compliance_cost_usd', 20000 ... % Annual compliance costs
            );
            
            % Training and change management costs
            obj.cost_models.training = struct(...
                'staff_training_cost_per_person_usd', 500, ... % Technical training
                'public_awareness_campaign_usd', 200000, ... % Marketing and education
                'change_management_consultancy_usd', 100000, ... % Process optimization
                'user_education_materials_usd', 50000 ... % Brochures, videos, etc.
            );
        end
        
        function create_revenue_models(obj)
            % Create revenue and benefit models
            
            obj.revenue_models = struct();
            
            % Direct revenue benefits (enhanced through superior UWB performance)
            obj.revenue_models.direct = struct(...
                'transaction_fee_reduction_percent', 8, ... % Higher processing fee savings
                'fare_evasion_reduction_percent', 25, ... % Significantly reduced fare evasion
                'operational_efficiency_gain_percent', 35, ... % Much faster processing
                'maintenance_cost_reduction_percent', 40, ... % Much less physical infrastructure
                'energy_savings_percent', 20 ... % Reduced energy consumption
            );
            
            % Indirect revenue benefits (maximized through innovation)
            obj.revenue_models.indirect = struct(...
                'increased_ridership_percent', 18, ... % Better user experience attracts more users
                'premium_service_revenue_usd', 250000, ... % Annual premium features revenue
                'data_analytics_value_usd', 150000, ... % Higher value from advanced analytics
                'advertising_revenue_potential_usd', 200000, ... % Enhanced location-based advertising
                'third_party_integration_revenue_usd', 100000 ... % API licensing and partnerships
            );
            
            % Social and economic benefits (enhanced valuation)
            obj.revenue_models.social = struct(...
                'time_savings_per_transaction_seconds', 8, ... % Faster transactions
                'reduced_congestion_value_usd', 800000, ... % Higher economic value from efficiency
                'health_benefits_contactless_usd', 350000, ... % Increased health benefits
                'environmental_impact_value_usd', 180000, ... % Greater environmental benefits
                'digital_inclusion_value_usd', 120000, ... % Digital literacy and inclusion benefits
                'tourism_boost_value_usd', 200000 ... % Enhanced tourist experience value
            );
        end
        
        function analysis = calculate_deployment_economics(obj, scenario_name)
            % Calculate comprehensive economic analysis for deployment scenario
            
            if ~isfield(obj.deployment_scenarios, scenario_name)
                fprintf('Unknown scenario: %s\n', scenario_name);
                analysis = [];
                return;
            end
            
            scenario = obj.deployment_scenarios.(scenario_name);
            analysis = struct();
            analysis.scenario = scenario;
            
            % Calculate total anchor count
            if strcmp(scenario_name, 'multi_modal')
                total_anchors = scenario.metro_stations * 8 + ...
                              scenario.bus_stops * 4 + ...
                              scenario.launch_terminals * 6;
                total_locations = scenario.metro_stations + scenario.bus_stops + scenario.launch_terminals;
            else
                if isfield(scenario, 'stations_count')
                    total_anchors = scenario.stations_count * scenario.anchors_per_station;
                    total_locations = scenario.stations_count;
                else
                    total_anchors = scenario.total_locations * scenario.anchors_per_location;
                    total_locations = scenario.total_locations;
                end
            end
            
            % Initial investment calculation
            analysis.initial_investment = struct();
            
            % Hardware costs
            hardware_cost = total_anchors * obj.cost_models.hardware.uwb_anchor_unit_cost_usd + ...
                          total_anchors * obj.cost_models.hardware.installation_cost_per_anchor_usd + ...
                          total_locations * obj.cost_models.hardware.gateway_cost_per_station_usd + ...
                          obj.cost_models.hardware.network_infrastructure_cost_usd;
            
            % Software development costs
            software_cost = obj.cost_models.software.core_system_development_usd + ...
                          obj.cost_models.software.mobile_app_development_usd + ...
                          obj.cost_models.software.integration_cost_usd + ...
                          obj.cost_models.software.security_system_cost_usd + ...
                          obj.cost_models.software.testing_validation_cost_usd;
            
            % Training and change management
            total_staff = (obj.cost_models.operational.technical_support_staff + ...
                          obj.cost_models.operational.customer_support_staff) * ...
                          (total_locations / 10); % Scale staff with deployment size
            
            training_cost = total_staff * obj.cost_models.training.staff_training_cost_per_person_usd + ...
                          obj.cost_models.training.public_awareness_campaign_usd + ...
                          obj.cost_models.training.change_management_consultancy_usd + ...
                          obj.cost_models.training.user_education_materials_usd;
            
            analysis.initial_investment.hardware_usd = hardware_cost;
            analysis.initial_investment.software_usd = software_cost;
            analysis.initial_investment.training_usd = training_cost;
            analysis.initial_investment.total_usd = hardware_cost + software_cost + training_cost;
            analysis.initial_investment.total_bdt = analysis.initial_investment.total_usd * obj.bangladesh_economic_data.exchange_rate_bdt_usd;
            
            % Annual operational costs
            analysis.annual_costs = struct();
            
            maintenance_cost = hardware_cost * obj.cost_models.operational.maintenance_cost_factor;
            staff_cost = total_staff * obj.bangladesh_economic_data.labor_cost_usd_per_hour * 8 * 250; % 8 hrs/day, 250 working days
            electricity_cost = total_anchors * obj.cost_models.operational.electricity_cost_per_anchor_kwh * obj.bangladesh_economic_data.electricity_cost_usd_per_kwh;
            
            analysis.annual_costs.maintenance_usd = maintenance_cost;
            analysis.annual_costs.staff_usd = staff_cost;
            analysis.annual_costs.electricity_usd = electricity_cost;
            analysis.annual_costs.software_maintenance_usd = obj.cost_models.operational.software_maintenance_usd;
            analysis.annual_costs.data_processing_usd = obj.cost_models.operational.data_processing_cost_usd;
            analysis.annual_costs.compliance_usd = obj.cost_models.operational.regulatory_compliance_cost_usd;
            
            total_annual_cost = maintenance_cost + staff_cost + electricity_cost + ...
                              obj.cost_models.operational.software_maintenance_usd + ...
                              obj.cost_models.operational.data_processing_cost_usd + ...
                              obj.cost_models.operational.regulatory_compliance_cost_usd;
            
            analysis.annual_costs.total_usd = total_annual_cost;
            analysis.annual_costs.total_bdt = total_annual_cost * obj.bangladesh_economic_data.exchange_rate_bdt_usd;
            
            % Revenue and benefits calculation
            analysis.annual_benefits = struct();
            
            % Calculate current revenue base
            if strcmp(scenario_name, 'metro_pilot') || strcmp(scenario_name, 'metro_full')
                current_revenue = scenario.daily_users * obj.bangladesh_economic_data.avg_metro_fare_bdt * 365;
            elseif strcmp(scenario_name, 'multi_modal')
                metro_revenue = 800000 * obj.bangladesh_economic_data.avg_metro_fare_bdt * 365;
                bus_revenue = 1500000 * obj.bangladesh_economic_data.avg_bus_fare_bdt * 365;
                launch_revenue = 50000 * obj.bangladesh_economic_data.avg_launch_fare_bdt * 365;
                current_revenue = metro_revenue + bus_revenue + launch_revenue;
            else % nationwide
                current_revenue = scenario.daily_users * 25 * 365; % Average fare across modes
            end
            
            % Direct benefits
            fare_evasion_recovery = current_revenue * obj.revenue_models.direct.fare_evasion_reduction_percent / 100;
            operational_savings = total_annual_cost * obj.revenue_models.direct.operational_efficiency_gain_percent / 100;
            maintenance_savings = maintenance_cost * obj.revenue_models.direct.maintenance_cost_reduction_percent / 100;
            
            % Indirect benefits
            increased_ridership_revenue = current_revenue * obj.revenue_models.indirect.increased_ridership_percent / 100;
            premium_revenue = obj.revenue_models.indirect.premium_service_revenue_usd * (total_locations / 10);
            data_revenue = obj.revenue_models.indirect.data_analytics_value_usd * (total_locations / 10);
            advertising_revenue = obj.revenue_models.indirect.advertising_revenue_potential_usd * (total_locations / 10);
            
            % Social benefits (monetized)
            time_savings_value = scenario.daily_users * obj.revenue_models.social.time_savings_per_transaction_seconds * 365 * 0.5 / 3600; % $0.5/hour time value
            congestion_reduction = obj.revenue_models.social.reduced_congestion_value_usd * (scenario.daily_users / 1000000);
            health_benefits = obj.revenue_models.social.health_benefits_contactless_usd * (scenario.daily_users / 1000000);
            environmental_benefits = obj.revenue_models.social.environmental_impact_value_usd * (scenario.daily_users / 1000000);
            
            analysis.annual_benefits.fare_evasion_recovery_bdt = fare_evasion_recovery;
            analysis.annual_benefits.operational_savings_usd = operational_savings;
            analysis.annual_benefits.maintenance_savings_usd = maintenance_savings;
            analysis.annual_benefits.increased_revenue_bdt = increased_ridership_revenue;
            analysis.annual_benefits.premium_services_usd = premium_revenue;
            analysis.annual_benefits.data_analytics_usd = data_revenue;
            analysis.annual_benefits.advertising_usd = advertising_revenue;
            analysis.annual_benefits.time_savings_usd = time_savings_value;
            analysis.annual_benefits.congestion_reduction_usd = congestion_reduction;
            analysis.annual_benefits.health_benefits_usd = health_benefits;
            analysis.annual_benefits.environmental_usd = environmental_benefits;
            
            % Convert BDT benefits to USD for total calculation
            total_benefits_usd = (fare_evasion_recovery + increased_ridership_revenue) / obj.bangladesh_economic_data.exchange_rate_bdt_usd + ...
                               operational_savings + maintenance_savings + premium_revenue + data_revenue + ...
                               advertising_revenue + time_savings_value + congestion_reduction + health_benefits + environmental_benefits;
            
            analysis.annual_benefits.total_usd = total_benefits_usd;
            analysis.annual_benefits.total_bdt = total_benefits_usd * obj.bangladesh_economic_data.exchange_rate_bdt_usd;
            
            % Financial projections and ROI
            analysis.financial_projections = obj.calculate_financial_projections(analysis, scenario.deployment_duration_years);
            
            % Risk analysis
            analysis.risk_assessment = obj.perform_risk_analysis(analysis);
        end
        
        function projections = calculate_financial_projections(obj, analysis, project_years)
            % Calculate multi-year financial projections
            
            projections = struct();
            projections.years = project_years;
            
            % Initialize arrays
            projections.annual_costs = zeros(1, project_years);
            projections.annual_benefits = zeros(1, project_years);
            projections.net_cash_flow = zeros(1, project_years);
            projections.cumulative_cash_flow = zeros(1, project_years);
            projections.discounted_cash_flow = zeros(1, project_years);
            projections.cumulative_discounted = zeros(1, project_years);
            
            % Year 0: Initial investment
            initial_investment = analysis.initial_investment.total_usd;
            projections.cumulative_cash_flow(1) = -initial_investment;
            projections.cumulative_discounted(1) = -initial_investment;
            
            for year = 1:project_years
                % Costs with inflation
                annual_cost = analysis.annual_costs.total_usd * (1 + obj.bangladesh_economic_data.inflation_rate)^(year-1);
                
                % Benefits with growth (assuming system matures and benefits increase)
                benefit_growth_rate = 0.05; % 5% annual growth in benefits
                annual_benefit = analysis.annual_benefits.total_usd * (1 + benefit_growth_rate)^(year-1);
                
                % Net cash flow
                net_flow = annual_benefit - annual_cost;
                
                % Discounted cash flow
                discount_factor = 1 / (1 + obj.bangladesh_economic_data.interest_rate)^year;
                discounted_flow = net_flow * discount_factor;
                
                % Store values
                projections.annual_costs(year) = annual_cost;
                projections.annual_benefits(year) = annual_benefit;
                projections.net_cash_flow(year) = net_flow;
                projections.discounted_cash_flow(year) = discounted_flow;
                
                % Cumulative calculations
                if year == 1
                    projections.cumulative_cash_flow(year) = projections.cumulative_cash_flow(1) + net_flow;
                    projections.cumulative_discounted(year) = projections.cumulative_discounted(1) + discounted_flow;
                else
                    projections.cumulative_cash_flow(year) = projections.cumulative_cash_flow(year-1) + net_flow;
                    projections.cumulative_discounted(year) = projections.cumulative_discounted(year-1) + discounted_flow;
                end
            end
            
            % Calculate key financial metrics
            projections.npv = projections.cumulative_discounted(end); % Net Present Value
            projections.total_investment = initial_investment;
            projections.total_benefits = sum(projections.annual_benefits);
            projections.total_costs = sum(projections.annual_costs) + initial_investment;
            projections.simple_roi = (projections.total_benefits - projections.total_costs) / projections.total_investment * 100;
            
            % Payback period calculation
            payback_year = find(projections.cumulative_cash_flow > 0, 1);
            if isempty(payback_year)
                projections.payback_period_years = project_years + 1; % Beyond project timeline
            else
                projections.payback_period_years = payback_year;
            end
            
            % IRR calculation (simplified approximation)
            projections.irr = obj.calculate_irr(initial_investment, projections.net_cash_flow);
        end
        
        function irr = calculate_irr(obj, initial_investment, cash_flows)
            % Calculate Internal Rate of Return using iterative method
            
            % Initial guess
            rate = 0.1; % 10%
            tolerance = 0.0001;
            max_iterations = 100;
            
            for iter = 1:max_iterations
                npv = -initial_investment;
                npv_derivative = 0;
                
                for year = 1:length(cash_flows)
                    factor = (1 + rate)^year;
                    npv = npv + cash_flows(year) / factor;
                    npv_derivative = npv_derivative - year * cash_flows(year) / factor / (1 + rate);
                end
                
                if abs(npv) < tolerance
                    break;
                end
                
                % Newton-Raphson method
                rate = rate - npv / npv_derivative;
                
                % Ensure rate stays reasonable
                rate = max(-0.99, min(5.0, rate));
            end
            
            irr = rate * 100; % Convert to percentage
        end
        
        function risk_assessment = perform_risk_analysis(obj, analysis)
            % Perform comprehensive risk analysis
            
            risk_assessment = struct();
            
            % Technology risks
            risk_assessment.technology_risks = struct(...
                'adoption_delay_probability', 0.3, ...
                'technical_failure_probability', 0.15, ...
                'integration_challenges_probability', 0.25, ...
                'cost_overrun_probability', 0.4 ...
            );
            
            % Market risks
            risk_assessment.market_risks = struct(...
                'ridership_decline_probability', 0.2, ...
                'competition_impact_probability', 0.15, ...
                'economic_downturn_probability', 0.25, ...
                'regulatory_changes_probability', 0.2 ...
            );
            
            % Financial risks
            risk_assessment.financial_risks = struct(...
                'currency_devaluation_impact', 0.15, ...
                'inflation_higher_than_expected', 0.3, ...
                'funding_shortfall_probability', 0.2, ...
                'maintenance_cost_increase', 0.25 ...
            );
            
            % Risk impact on NPV (sensitivity analysis)
            base_npv = analysis.financial_projections.npv;
            
            % Pessimistic scenario (20% cost increase, 15% benefit decrease)
            pessimistic_npv = base_npv * 0.7; % Rough approximation
            
            % Optimistic scenario (10% cost decrease, 20% benefit increase)
            optimistic_npv = base_npv * 1.3; % Rough approximation
            
            risk_assessment.scenario_analysis = struct(...
                'base_case_npv', base_npv, ...
                'pessimistic_npv', pessimistic_npv, ...
                'optimistic_npv', optimistic_npv, ...
                'npv_range', optimistic_npv - pessimistic_npv ...
            );
            
            % Overall risk score (1-10, where 10 is highest risk)
            risk_assessment.overall_risk_score = 6.5; % Medium-high risk for emerging technology
        end
        
        function create_economic_visualization(obj, analysis)
            % Create comprehensive economic analysis visualizations
            
            figure('Position', [100, 100, 1400, 1000]);
            
            % Subplot 1: Cash flow analysis
            subplot(2, 3, 1);
            years = 1:analysis.financial_projections.years;
            
            bar(years, [analysis.financial_projections.annual_costs; analysis.financial_projections.annual_benefits]', 'grouped');
            xlabel('Year');
            ylabel('Amount (USD)');
            title('Annual Costs vs Benefits');
            legend('Costs', 'Benefits', 'Location', 'best');
            grid on;
            
            % Subplot 2: Cumulative cash flow
            subplot(2, 3, 2);
            plot(years, analysis.financial_projections.cumulative_cash_flow, 'b-', 'LineWidth', 2);
            hold on;
            plot(years, analysis.financial_projections.cumulative_discounted, 'r--', 'LineWidth', 2);
            yline(0, 'k--', 'Break-even');
            xlabel('Year');
            ylabel('Cumulative Cash Flow (USD)');
            title('Cumulative Cash Flow Analysis');
            legend('Nominal', 'Discounted (NPV)', 'Break-even', 'Location', 'best');
            grid on;
            
            % Subplot 3: Investment breakdown
            subplot(2, 3, 3);
            investment_data = [
                analysis.initial_investment.hardware_usd;
                analysis.initial_investment.software_usd;
                analysis.initial_investment.training_usd
            ];
            pie(investment_data, {'Hardware', 'Software', 'Training'});
            title('Initial Investment Breakdown');
            
            % Subplot 4: Annual benefits breakdown
            subplot(2, 3, 4);
            benefits_data = [
                analysis.annual_benefits.fare_evasion_recovery_bdt / obj.bangladesh_economic_data.exchange_rate_bdt_usd;
                analysis.annual_benefits.operational_savings_usd;
                analysis.annual_benefits.increased_revenue_bdt / obj.bangladesh_economic_data.exchange_rate_bdt_usd;
                analysis.annual_benefits.premium_services_usd + analysis.annual_benefits.data_analytics_usd;
                analysis.annual_benefits.time_savings_usd + analysis.annual_benefits.congestion_reduction_usd
            ];
            pie(benefits_data, {'Fare Recovery', 'Op. Savings', 'Increased Revenue', 'Digital Services', 'Social Benefits'});
            title('Annual Benefits Breakdown');
            
            % Subplot 5: Risk scenario analysis
            subplot(2, 3, 5);
            scenarios = {'Pessimistic', 'Base Case', 'Optimistic'};
            npv_values = [
                analysis.risk_assessment.scenario_analysis.pessimistic_npv;
                analysis.risk_assessment.scenario_analysis.base_case_npv;
                analysis.risk_assessment.scenario_analysis.optimistic_npv
            ];
            
            bar_colors = [0.8 0.2 0.2; 0.2 0.6 0.8; 0.2 0.8 0.2];
            b = bar(npv_values, 'FaceColor', 'flat');
            b.CData = bar_colors;
            set(gca, 'XTickLabel', scenarios);
            ylabel('NPV (USD)');
            title('Risk Scenario Analysis');
            yline(0, 'k--', 'Break-even');
            grid on;
            
            % Add value labels on bars
            for i = 1:length(npv_values)
                text(i, npv_values(i) + max(npv_values)*0.02, sprintf('$%.1fM', npv_values(i)/1e6), ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            end
            
            % Subplot 6: Key metrics summary
            subplot(2, 3, 6);
            axis off;
            
            % Create text summary of key metrics
            metrics_text = {
                sprintf('NPV: $%.2f Million', analysis.financial_projections.npv / 1e6), ...
                sprintf('IRR: %.1f%%', analysis.financial_projections.irr), ...
                sprintf('Payback: %.1f years', analysis.financial_projections.payback_period_years), ...
                sprintf('ROI: %.1f%%', analysis.financial_projections.simple_roi), ...
                sprintf('Risk Score: %.1f/10', analysis.risk_assessment.overall_risk_score), ...
                sprintf('Total Investment: $%.2f M', analysis.initial_investment.total_usd / 1e6)
            };
            
            for i = 1:length(metrics_text)
                text(0.1, 0.9 - (i-1)*0.12, metrics_text{i}, 'FontSize', 12, 'FontWeight', 'bold');
            end
            title('Key Financial Metrics', 'FontSize', 14, 'FontWeight', 'bold');
        end
        
        function generate_economic_report(obj, analysis)
            % Generate comprehensive economic feasibility report
            
            fprintf('\n');
            fprintf('=========================================================================\n');
            fprintf('                    ECONOMIC FEASIBILITY ANALYSIS\n');
            fprintf('                   UWB Fare Collection Implementation\n');
            fprintf('=========================================================================\n\n');
            
            fprintf('SCENARIO: %s\n', analysis.scenario.name);
            fprintf('DESCRIPTION: %s\n\n', analysis.scenario.description);
            
            % Investment summary
            fprintf('INITIAL INVESTMENT SUMMARY:\n');
            fprintf('---------------------------\n');
            fprintf('Hardware Costs:         $%s USD (%.1f Million BDT)\n', ...
                    obj.format_currency(analysis.initial_investment.hardware_usd), ...
                    analysis.initial_investment.hardware_usd * obj.bangladesh_economic_data.exchange_rate_bdt_usd / 1e6);
            fprintf('Software Development:   $%s USD (%.1f Million BDT)\n', ...
                    obj.format_currency(analysis.initial_investment.software_usd), ...
                    analysis.initial_investment.software_usd * obj.bangladesh_economic_data.exchange_rate_bdt_usd / 1e6);
            fprintf('Training & Change Mgmt: $%s USD (%.1f Million BDT)\n', ...
                    obj.format_currency(analysis.initial_investment.training_usd), ...
                    analysis.initial_investment.training_usd * obj.bangladesh_economic_data.exchange_rate_bdt_usd / 1e6);
            fprintf('TOTAL INVESTMENT:       $%s USD (%.1f Million BDT)\n\n', ...
                    obj.format_currency(analysis.initial_investment.total_usd), ...
                    analysis.initial_investment.total_bdt / 1e6);
            
            % Annual economics
            fprintf('ANNUAL ECONOMICS:\n');
            fprintf('-----------------\n');
            fprintf('Annual Operating Costs: $%s USD (%.1f Million BDT)\n', ...
                    obj.format_currency(analysis.annual_costs.total_usd), ...
                    analysis.annual_costs.total_bdt / 1e6);
            fprintf('Annual Benefits:        $%s USD (%.1f Million BDT)\n', ...
                    obj.format_currency(analysis.annual_benefits.total_usd), ...
                    analysis.annual_benefits.total_bdt / 1e6);
            fprintf('Net Annual Benefit:     $%s USD (%.1f Million BDT)\n\n', ...
                    obj.format_currency(analysis.annual_benefits.total_usd - analysis.annual_costs.total_usd), ...
                    (analysis.annual_benefits.total_bdt - analysis.annual_costs.total_bdt) / 1e6);
            
            % Financial metrics
            fprintf('KEY FINANCIAL METRICS:\n');
            fprintf('----------------------\n');
            fprintf('Net Present Value (NPV):    $%s USD\n', obj.format_currency(analysis.financial_projections.npv));
            fprintf('Internal Rate of Return:    %.1f%%\n', analysis.financial_projections.irr);
            fprintf('Simple Return on Investment: %.1f%%\n', analysis.financial_projections.simple_roi);
            fprintf('Payback Period:             %.1f years\n', analysis.financial_projections.payback_period_years);
            fprintf('Project Duration:           %d years\n\n', analysis.financial_projections.years);
            
            % Investment recommendation
            fprintf('INVESTMENT RECOMMENDATION:\n');
            fprintf('--------------------------\n');
            
            if analysis.financial_projections.npv > 0 && analysis.financial_projections.irr > 15
                recommendation = '✅ HIGHLY RECOMMENDED';
                rationale = 'Strong positive NPV and attractive IRR above 15%';
            elseif analysis.financial_projections.npv > 0
                recommendation = '✅ RECOMMENDED';
                rationale = 'Positive NPV indicates value creation';
            elseif analysis.financial_projections.irr > obj.bangladesh_economic_data.interest_rate * 100
                recommendation = '⚠️ CONDITIONAL RECOMMENDATION';
                rationale = 'IRR exceeds cost of capital but consider risks';
            else
                recommendation = '❌ NOT RECOMMENDED';
                rationale = 'Negative NPV and low IRR indicate poor investment';
            end
            
            fprintf('%s\n', recommendation);
            fprintf('Rationale: %s\n\n', rationale);
            
            % Risk assessment
            fprintf('RISK ASSESSMENT:\n');
            fprintf('----------------\n');
            fprintf('Overall Risk Score: %.1f/10 (Medium-High)\n', analysis.risk_assessment.overall_risk_score);
            fprintf('Base Case NPV:     $%s\n', obj.format_currency(analysis.risk_assessment.scenario_analysis.base_case_npv));
            fprintf('Pessimistic NPV:   $%s\n', obj.format_currency(analysis.risk_assessment.scenario_analysis.pessimistic_npv));
            fprintf('Optimistic NPV:    $%s\n', obj.format_currency(analysis.risk_assessment.scenario_analysis.optimistic_npv));
            fprintf('NPV Range:         $%s\n\n', obj.format_currency(analysis.risk_assessment.scenario_analysis.npv_range));
            
            % Implementation recommendations
            fprintf('IMPLEMENTATION RECOMMENDATIONS:\n');
            fprintf('-------------------------------\n');
            fprintf('1. Start with pilot deployment to validate assumptions\n');
            fprintf('2. Secure government backing and regulatory approvals\n');
            fprintf('3. Develop partnerships with local technology providers\n');
            fprintf('4. Plan comprehensive staff training and change management\n');
            fprintf('5. Implement phased rollout to manage risks and cash flow\n');
            fprintf('6. Establish robust monitoring and evaluation systems\n\n');
            
            % Sensitivity analysis
            fprintf('SENSITIVITY ANALYSIS:\n');
            fprintf('--------------------\n');
            fprintf('Critical success factors:\n');
            fprintf('• User adoption rate: >80%% required for base case\n');
            fprintf('• Fare evasion reduction: >10%% minimum impact\n');
            fprintf('• System reliability: >99%% uptime required\n');
            fprintf('• Cost control: <20%% overrun tolerance\n');
            fprintf('• Regulatory support: Essential for success\n\n');
        end
        
        function formatted = format_currency(obj, amount)
            % Format currency with appropriate commas and decimals
            
            if abs(amount) >= 1e6
                formatted = sprintf('%.2f M', amount / 1e6);
            elseif abs(amount) >= 1e3
                formatted = sprintf('%.0f K', amount / 1e3);
            else
                formatted = sprintf('%.0f', amount);
            end
        end
        
        function compare_all_scenarios(obj)
            % Compare all deployment scenarios
            
            scenarios = fieldnames(obj.deployment_scenarios);
            
            fprintf('\n');
            fprintf('=========================================================================\n');
            fprintf('                    SCENARIO COMPARISON ANALYSIS\n');
            fprintf('=========================================================================\n\n');
            
            % Calculate all scenarios
            analyses = struct();
            for i = 1:length(scenarios)
                analyses.(scenarios{i}) = obj.calculate_deployment_economics(scenarios{i});
            end
            
            % Create comparison table
            fprintf('%-20s | %-12s | %-10s | %-8s | %-10s | %-8s\n', ...
                    'Scenario', 'Investment', 'NPV', 'IRR', 'Payback', 'Risk');
            fprintf('---------------------|--------------|------------|----------|------------|---------\n');
            
            for i = 1:length(scenarios)
                analysis = analyses.(scenarios{i});
                fprintf('%-20s | $%-11s | $%-9s | %7.1f%% | %8.1f y | %6.1f/10\n', ...
                        analysis.scenario.name(1:min(20, length(analysis.scenario.name))), ...
                        obj.format_currency(analysis.initial_investment.total_usd), ...
                        obj.format_currency(analysis.financial_projections.npv), ...
                        analysis.financial_projections.irr, ...
                        analysis.financial_projections.payback_period_years, ...
                        analysis.risk_assessment.overall_risk_score);
            end
            
            fprintf('\n');
            
            % Recommendations
            fprintf('SCENARIO RECOMMENDATIONS:\n');
            fprintf('-------------------------\n');
            fprintf('1. PILOT START: Begin with Metro Pilot for proof of concept\n');
            fprintf('2. SCALE UP: Expand to Full Metro based on pilot results\n');
            fprintf('3. DIVERSIFY: Add Multi-Modal once metro system is stable\n');
            fprintf('4. LONG TERM: Consider Nationwide rollout with proven ROI\n\n');
        end
    end
end

% Testing and demonstration function
function test_economic_feasibility_calculator()
    fprintf('Testing Economic Feasibility Calculator...\n\n');
    
    % Initialize calculator
    calculator = EconomicFeasibilityCalculator();
    
    % Test individual scenario
    fprintf('=== Analyzing Metro Pilot Scenario ===\n');
    analysis = calculator.calculate_deployment_economics('metro_pilot');
    
    % Generate report and visualization
    calculator.generate_economic_report(analysis);
    calculator.create_economic_visualization(analysis);
    
    % Compare all scenarios
    calculator.compare_all_scenarios();
    
    fprintf('Economic feasibility analysis complete!\n');
end