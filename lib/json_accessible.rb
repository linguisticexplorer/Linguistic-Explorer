module JsonAccessible
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def json_accessor(*names)
      names.each do |name|
        define_method("#{name}_json") do
          self.send(name).to_json
        end

        define_method("#{name}_json=") do |*args|
          self.send("#{name}=", JSON.parse(args.first))
        end
      end
    end
  end
end
