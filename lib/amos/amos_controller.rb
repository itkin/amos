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
        control_error "Parent model not found" do
          @parent_model = params[:parent_model].singularize.camelize.constantize
          @relation = params[:model].underscore.to_sym
          @macro = @parent_model.reflections[@relation].macro
        end
      end

      def set_model
        control_error "Model not found" do
          @model = params[:model].singularize.camelize.constantize
        end
      end

      def set_attributes
        @attributes = remove_attributes_from ['parent_model', 'parent_id', 'fields','format','id', 'model', 'controller', 'action'], params.clone
        @attributes.underscore_keys!
        @attributes = set_association_keys_for(@model, @attributes[@model.name.underscore] || @attributes)
      end

      def set_parent_record
        control_error "Parent record #{params[:parent_model]} #{params[:parent_id]} not found" do
          @parent_record = @parent_model.find(params[:parent_id])
        end
      end

      def set_record
        control_error do
          if @parent_record and @macro == :has_many
            @record = @parent_record.send(@relation).find(params[:id])
          elsif @parent_record
            @record = @parent_record.send(@relation)
            if params[:id] and @record.id != params[:id].to_i
              raise ActiveRecord::RecordNotFound, "Record #{params[:id]} doesn't belongs_to #{@parent_model.name}.#{@relation}"
            end
          else
            begin
              @record = @model.find(params[:id])
            rescue
              raise ActiveRecord::RecordNotFound, "Record #{params[:id]} not found"
            end
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
        render :json => error, :status => code and return
      end

      def control_error error_message=nil, code=400, errorClass=Exception, &block
        begin
          block.call
        rescue errorClass => e
          render_error(error_message || e.message, code) unless performed?
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
        authorize :read do
          options = remove_attributes_from ['parent_model', 'parent_id','updating', 'offset', 'format', 'limit','count', 'fields', 'model', 'controller', 'action'], params.clone
          options.underscore_keys!

          if @parent_record
            @records = @parent_record.send(@relation).list(options)
          else
            @records = @model.list(options)
          end

          render_records(@records)
        end
      end
      def show
        authorize :read do
          render_record(@record)
        end
      end
      def create
        authorize :create do

          if @parent_record and @macro == :has_many
            @record = @parent_record.send(@relation).new(@attributes)
          elsif @parent_record
            @record = @parent_record.send "build_#{@relation}", @attributes
          else
            @record = @model.new(@attributes)
          end

          if (@parent_record || @record).save
            render_record(@record)
          else
            render_error(@record.errors, 400)
          end
        end
      end
      def update
        authorize :update do
          @record.attributes=(@attributes)
          if (@parent_record || @record).save
            render_record(@record)
          else
            render_error(@record.errors, 400) #406 :not_acceptable
          end
        end
      end
      def destroy
        authorize :delete do
          if @record.destroy
            render :json => {:success => "true"}
          else
            render_error(@record.errors)
          end
        end
      end
    end
  end

end