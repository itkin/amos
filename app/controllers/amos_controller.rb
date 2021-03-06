 require 'cancan'
 require 'ruby-debug'
 
  class AmosController < ApplicationController

    unloadable

    before_filter :set_model
    before_filter :set_current_record, :only => [:show, :update, :destroy]
    #before_filter :should_paginate
    
    def index
      options = remove_attributes_from ['offset', 'limit','count', 'fields', 'model', 'controller', 'action'], params.clone
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
      attributes = remove_attributes_from ['fields','id', 'model', 'controller', 'action'], params.clone
      attributes.underscore_keys!
      attributes = set_association_keys_for(@model, attributes)

      record = @model.new(attributes)
      if record.save
          render :json => record.as_json(params[:fields])
      else
          render :json => record.errors, :status => 400
      end
    else
      render_authorized
    end
  end
    
  def update
    if can? :update, @model
      attributes = remove_attributes_from ['fields', 'id', 'model', 'controller', 'action'], params.clone
      attributes.underscore_keys!
      attributes = set_association_keys_for(@model, attributes)

      if @record.update_attributes(attributes)
        render :json => record.as_json(params[:fields])
      else
        render :json => @record.errors, :status => 400
      end
    else
      render_authorized
    end
  end

  protected
  
    def set_model
      begin
        @model = params[:model].gsub(/\.json$/i,'').singularize.camelize.constantize
      rescue
        render :json => {:error => "Model not found"}, :status => 400
      end
      if cannot? :read, @model
        render_authorized
      end
    end

    def remove_attributes_from attribute_names, collection
      attribute_names.each{|key| collection.delete(key)}
      collection
    end
  
    def set_current_record
      begin
        @record = @model.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render :json => {:error => "Record #{params[:id]} not found"}, :status => 400
      end
    end

    def render_authorized
      render :json => {:error => "You are not authorized to access this data"}, :status => 401
    end


    
  end

