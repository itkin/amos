module Amos

  module ApplicationController

    def self.included(base)
      base.class_eval do
        def crudify
          before_filter :set_model
          before_filter :set_current_record, :only => [:show, :update, :destroy]

          base.send :include, Amos::InstanceMethods
        end
      end

    end

    def set_association_keys_for(klass, hash)
      hash.replace_keys!(klass.reflections.keys.flatten.map { |name| { "#{name}" => "#{name}_attributes"} })
    end

    def remove_attributes_from attribute_names, collection
      attribute_names.each{|key| collection.delete(key)}
      collection
    end

  end

  module InstanceMethods

    def index
      options = remove_attributes_from ['updating', 'offset', 'format', 'limit','count', 'fields', 'model', 'controller', 'action'], params.clone
      options.underscore_keys!

      params[:limit] = params[:limit] ? params[:limit].to_i : nil
      params[:offset] = params[:offset] ? params[:offset].to_i : nil

      records = @model.list(options)

      render :json => {
        :data => records.limit(params[:limit]).offset(params[:offset]).as_json(params[:fields]),
        :offset => params[:offset],
        :limit => params[:limit],
        :count => records.count
      }
    end

    def show
      render :json => @record.as_json(params[:fields])
    end

    def destroy
      if can? :delete, @record
       @record.destroy
       render :json => {:success => "true"}
      else
       render_authorized
      end
    end

    def create
      if can? :create, @model
        @record = if @parent_record and @macro == :has_many
          @parent_record.send(relation).build(@attributes)
        elsif @parent_record
          @parent_record.send("build_#{@model_name}", @attributes)
        else
          @model.new(@attributes)
        end

        if (@parent_record || @record).save
          render :json => @record.as_json(params[:fields])
        else
          render :json => @record.errors, :status => 400
        end
      else
        render_authorized
      end
    end

    def update
      if can? :update, @model
        @record.attributes=(@attributes)
        if (@parent_record || @record).save
          render :json => @record.as_json(params[:fields])
        else
          render :json => @record.errors, :status => 400
        end
      else
        render_authorized
      end
    end

    protected

      def set_parent_model
        begin
          @parent_model = params[:parent].camelize.constantize if params[:parent]
          @relation = params[:model].gsub(/\.json$/i,'').underscore.to_sym
          @macro = @parent_model.reflections[@relation].macro
        rescue
          render :json => {:error => "Parent Model not found"}, :status => 400
        end
      end

      def set_model
        begin
          @model_name = @relation.to_s.singularize
          @model = @model_name.camelize.constantize
        rescue
          render :json => {:error => "Model not found"}, :status => 400
        end

        if cannot? :read, @model
          render_authorized
        end
      end

      def set_attributes
        @attributes = remove_attributes_from ['parent', 'parent_id', 'fields','format','id', 'model', 'controller', 'action'], params.clone
        @attributes.underscore_keys!
        @attributes = set_association_keys_for(@model, @attributes)
      end

      def set_parent_record
        begin
          @parent_record = @parent_model.find(params[:parent_id])
        rescue ActiveRecord::RecordNotFound => e
          render :json => {:error => "Parent record #{params[:parent]} #{params[:parent_id]} not found"}, :status => 400
        end
      end

      def set_current_record
        begin
          @record = if @parent_record and @macro == :has_many
            @parent_record.send(@relation).find(:id)
          elsif @parent_record
            @parent_record.send(@relation)
          else
            @model.find(params[:id])
          end
        rescue ActiveRecord::RecordNotFound => e
          render :json => {:error => "Record #{params[:id]} not found"}, :status => 400
        end
      end

      def render_authorized
        render :json => {:error => "You are not authorized to access this data"}, :status => 401
      end

  end

end