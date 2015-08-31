class Event
  attr_reader :frequency, :name

  def initialize(name, frequency, dependency_proc=nil)
    @name = name
    @frequency = frequency
    @dependency_proc = dependency_proc
  end

  def is_valid?(obj)
    if @dependency_proc.nil?
      true
    else
      obj.instance_eval(@dependency_proc)
    end
  end

  def occur(obj)
    obj.send(@name)
  end
end
