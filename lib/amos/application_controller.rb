module Amos
  module ApplicationController
    def self.included(base)
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
          before_filter :set_attributes, :only => [:update, :create]

          self.send :include, Amos::Controller::Base
        end
      end
    end
  end
end