# Helper methods for testing Stimulus controllers

module StimulusHelpers
  # Helper to trigger Stimulus controller actions in tests
  def trigger_stimulus_action(element, controller, action, params = {})
    element.click if action == "click"
    # Add other action triggers as needed
  end

  # Helper to check if Stimulus controller is connected
  def stimulus_controller_connected?(element, controller_name)
    element["data-controller"]&.include?(controller_name)
  end

  # Helper to get Stimulus controller data values
  def stimulus_data_value(element, controller, value_name)
    element["data-#{controller}-#{value_name.dasherize}-value"]
  end

  # Helper to set Stimulus controller data values
  def set_stimulus_data_value(element, controller, value_name, value)
    element.set("data-#{controller}-#{value_name.dasherize}-value", value)
  end

  # Helper to find elements by Stimulus target
  def find_stimulus_target(controller, target_name)
    find("[data-#{controller}-target='#{target_name}']")
  end

  # Helper to find all elements by Stimulus target
  def find_all_stimulus_targets(controller, target_name)
    all("[data-#{controller}-target='#{target_name}']")
  end

  # Helper to check if element has Stimulus target
  def has_stimulus_target?(element, controller, target_name)
    element["data-#{controller}-target"] == target_name
  end

  # Helper to simulate file drop on drag-drop zone
  def simulate_file_drop(drop_zone, files)
    # This would require more complex JavaScript execution
    # For now, we'll use the file input change event
    file_input = drop_zone.find('input[type="file"]', visible: false)
    file_input.attach_file(files)
  end

  # Helper to wait for Stimulus controller to be ready
  def wait_for_stimulus_controller(element, controller_name, timeout: 5)
    Timeout.timeout(timeout) do
      loop do
        break if stimulus_controller_connected?(element, controller_name)
        sleep 0.1
      end
    end
  rescue Timeout::Error
    raise "Stimulus controller '#{controller_name}' not connected within #{timeout} seconds"
  end
end

RSpec.configure do |config|
  config.include StimulusHelpers, type: :system
  config.include StimulusHelpers, type: :feature
end
