require 'digest/sha2'

class Stacks::Items::MethodCall

  def initialize(object, method, args)
    @object = object
    @method = method
    @args = args
  end

  def key_str
    return @key_str if @key_str

    object_str = Marshal.dump(@object)
    method_str = @method.to_s
    arg_str = Marshal.dump(@args)

    @key_str ||= [object_str, method_str, arg_str].join(Stacks::key_separator)
  end

  def key
    @key = Digest::SHA2.hexdigest(key_str)
  end

  def value
    @object.send(@method, *@args)
  end

end
