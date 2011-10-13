
require "amos"
require "rails"

module Amos
  class Engine < Rails::Engine
    paths.app.controllers << "lib/controllers"
    config.active_record.include_root_in_json = false

    initializer 'amos.application_controller' do |app|
      ActiveSupport.on_load(:action_controller) do
        include Amos::ApplicationController
      end
    end

  end
end