class Stacks::ReportCache

  extend Stacks::Cache

  attr_accessor(:report_name, :ttl, :values, :cache_condition)

  def self.reports
    @reports ||= {}
  end

  def self.get_report(report_name)
    raise "Invalid report name" unless @reports.keys.include?(report_name)
    reports[report_name]
  end

  def initialize(report_name, ttl)
    @report_name = report_name
    @values = {}
    @ttl = ttl
  end

  def set_cache_condition(&block)
    @cache_condition = block
  end

  def value(value_name, &block)
    @values[value_name] = Stacks::Items::Proc.new(value_name, block)
  end

  def get_item(item)
    if cache_condition
      Stacks.deactivate = true unless cache_condition.call
    end

    value = self.class.get_value(item, backend, @ttl)
    Stacks.deactivate = false
    value
  end

  def get_value(value_name)
    get_item(@values[value_name])
  end

  def timestamp
    get_item(Stacks::Items::Timestamp.new)
  end

  def fill_cache
    if cache_condition
      return unless cache_condition.call
    end

    @values.each { |value_name, item| backend.fill(item, @ttl) }
    backend.fill(Stacks::Items::Timestamp.new, @ttl)
  end

  def self.report(report_name, ttl, &block)
    report = new(report_name, ttl)
    report.instance_eval(&block)
    reports[report_name] = report
    report
  end

  def register_instance_variables(instance)
    values.each do |value_name, item|
      instance.instance_variable_set("@#{value_name}".to_sym, get_value(value_name))
    end
  end

  def backend
    return @backend if @backend

    backend = Stacks::Backends::NamespacedBackend.new
    backend.namespace = @report_name
    @backend ||= backend
  end

end
