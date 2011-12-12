
require "rails"

module Amos
  class Engine < Rails::Engine

    config.active_record.include_root_in_json = false

    initializer 'amos' do |app|
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send :include, Amos::ApplicationController

      end
    end

  end
end