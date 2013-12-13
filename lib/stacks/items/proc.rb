class Stacks::Items::Proc

  def initialize(identifier, proc)
    @identifier = identifier
    @proc = proc
  end

  def key
    @key ||= @identifier
  end

  def value
    @proc.call
  end

end
