module Amos
  module Controller
    module Helpers

      def set_association_keys_for(klass, hash)
        hash.replace_keys!(klass.reflections.keys.flatten.map { |name| { "#{name}" => "#{name}_attributes"} })
      end

      def remove_attributes_from attribute_names, collection
        attribute_names.each{|key| collection.delete(key)}
        collection
      end

      def set_parent_model
        control_error "Parent Model not found" do
          @parent_model = params[:parent_model].camelize.constantize
          @relation = params[:model].underscore.to_sym
          @macro = @parent_model.reflections[@relation].macro
        end
      end

      def set_model
        set_parent_model if params[:parent_model]
        control_error "Model not found" do
          @model = params[:model].singularize.camelize.constantize
        end

        authorize :read
      end

      def set_attributes
        @attributes = remove_attributes_from ['parent', 'parent_id', 'fields','format','id', 'model', 'controller', 'action'], params.clone
        @attributes.underscore_keys!
        @attributes = set_association_keys_for(@model, @attributes)
      end

      def set_parent_record
        control_error "Parent record #{params[:parent]} #{params[:parent_id]} not found" do
          @parent_record = @parent_model.find(params[:parent_id])
        end
      end

      def set_record
        control_error do
          if @parent_record and @macro == :has_many
            @record = @parent_record.send(@relation).find(:id)
          elsif @parent_record
            @record = @parent_record.send(@relation)
            if params[:id] and @record.id != params[:id].to_i
              raise ActiveRecord::RecordNotFound, "Record #{params[:id]} doesn't belongs_to #{@parent_model.name}.#{@relation}"
            end
          else
            @record = @model.find(params[:id])
          end
        end
      end

      def render_records(records)
        params[:limit] = params[:limit] ? params[:limit].to_i : nil
        params[:offset] = params[:offset] ? params[:offset].to_i : nil

        render :json => {
          :data => records.limit(params[:limit]).offset(params[:offset]).as_json(params[:fields]),
          :offset => params[:offset],
          :limit => params[:limit],
          :count => records.count
        }
      end

      def render_record(record)
        render :json => record.as_json(params[:fields])
      end

      def render_error(error, code=400)
        render :json => error, :status => code
      end

      def control_error error='', code=400, errorClass=Exception, &block
        begin
          block.call
        rescue errorClass => e
          render_error(error || e.message, code)
        end
      end

      def authorize(action, &block)
        if can? action, @model
          block.call if block
        else
          render_error "You are not authorized to access this data", 401
        end
      end

    end

    module Base
      include Amos::Controller::Helpers

      def index
        options = remove_attributes_from ['parent_model', 'parent_id','updating', 'offset', 'format', 'limit','count', 'fields', 'model', 'controller', 'action'], params.clone
        options.underscore_keys!

        if @parent_record
          @records = @parent_record.send(@relation).list(options)
        else
          @records = @model.list(options)
        end

        render_records(@records)
      end
      def show
        render_record(@record)
      end
      def create
        authorize :create do
          @model.new(@attributes)
          if (@parent_record || @record).save
            render_record(@record)
          else
            render_error(@record.errors, 413)
          end
        end
      end
      def update
        authorize :update do
          @record.attributes=(@attributes)
          if (@parent_record || @record).save
            render_record(@record)
          else
            render_error(@record.error,413)
          end
        end
      end
      def destroy
        authorize :delete do
          @record.destroy
          render :json => {:success => "true"}
        end
      end
    end
  end
  module ApplicationController
    def self.included(base)
      base.class_eval do
        def self.crudify
          before_filter :set_model
          before_filter :set_record, :only => [:show, :update, :destroy]
          before_filter :set_attributes, :only => [:update, :create]

          self.send :include, Amos::Controller::Base
        end
      end
    end
  end
end