module Amos
  module ApplicationController
    def self.included(base)
      base.send :include, Amos::Controller::Helpers

      base.class_eval do
        def self.crudify
          before_filter  do |controller|
            if params[:parent_model]
              controller.send :set_parent_model
              controller.send :set_parent_record
            end
          end
          before_filter :set_model
          before_filter :set_record, :only => [:show, :update, :destroy]

          before_filter :only => [:update, :create] do |controller|
            controller.send :set_attributes, controller.instance_variable_get(:@model)
          end

          self.send :include, Amos::Controller::Base
        end
      end
    end
  end
end