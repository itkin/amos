
require "rails"

module Amos
  class Engine < Rails::Engine

    config.active_record.include_root_in_json = false

    initializer 'amos' do |app|
      ActiveSupport.on_load(:before_initialize) do
        ::ApplicationController.send :include, Amos::ApplicationController
        AmosController.send :crudify
      end
    end

  end
end