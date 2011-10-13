module Amos
  module ApplicationController
    def set_association_keys_for(klass, hash)
      hash.replace_keys!(klass.reflections.keys.flatten.map { |name| { "#{name}" => "#{name}_attributes"} })
    end
  end
end