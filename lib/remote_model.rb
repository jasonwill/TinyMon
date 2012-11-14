module RemoteModule
  class RemoteModel
    class << self
      def attributes
        @attributes ||= []
      end
      
      def attributes=(value)
        @attributes = value
      end
      
      def attribute(*fields)
        attr_accessor *fields
        self.attributes += fields
      end
      
      def association(name, params)
        backwards_association = self.name.underscore
    
        define_method name do |&block|
          cached = instance_variable_get("@#{name}")
          block.call(cached) if cached
      
          Object.const_get(name.to_s.classify).find_all(params.call(self)) do |results|
            if results
              results.each do |result|
                result.send("#{backwards_association}=", self)
              end
            end
            instance_variable_set("@#{name}", results)
            block.call(results)
          end
        end
    
        define_method "reset_#{name}" do
          instance_variable_set("@#{name}", nil)
        end
      end
      
      def scope(name)
        metaclass.send(:define_method, name) do |&block|
          get(send("#{name}_url")) do |response, json|
            if response.ok?
              objs = []
              arr_rep = nil
              if json.class == Array
                arr_rep = json
              elsif json.class == Hash
                plural_sym = self.pluralize.to_sym
                if json.has_key? plural_sym
                  arr_rep = json[plural_sym]
                end
              else
                # the returned data was something else
                # ie a string, number
                request_block_call(block, nil, response)
                return
              end
              arr_rep.each { |one_obj_hash|
                objs << self.new(one_obj_hash)
              }
              request_block_call(block, objs, response)
            else
              request_block_call(block, nil, response)
            end
          end
        end
      end
    end
    
    def attributes
      self.class.attributes.inject({}) do |hash, attr|
        hash[attr] = send(attr)
        hash
      end
    end
    
    def save(&block)
      put(member_url, :payload => { self.class.name.underscore => attributes }) do |response, json|
        block.call json ? self.class.new(json) : nil
      end
    end
  
    def create(&block)
      post(collection_url, :payload => { self.class.name.underscore => attributes }) do |response, json|
        block.call json ? self.class.new(json) : nil
      end
    end
  
    def destroy(&block)
      delete(member_url) do |response, json|
        block.call json ? self.class.new(json) : nil
      end
    end
  end
end
