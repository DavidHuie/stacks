class Stacks::Items::ColumnDependentBlock

  attr_accessor :model

  def initialize(model, columns, identifier, proc)
    @model = model
    @columns = columns.sort!
    @columns = @columns.map { |c| c.to_s }
    @identifier = identifier
    @proc = proc
  end

  def key
    @key ||= [@identifier].concat(@columns).join(Stacks::key_separator)
  end

  def self.key_to_columns(key)
    all_keys = key.split(Stacks::key_separator)

    # The identifier takes the first slot
    all_keys.shift
    all_keys
  end

  def value
    @proc.call
  end

end
