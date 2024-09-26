class Foo
  attr_accessor :foo

  def initialize(foo)
    @foo = foo
  end

  def foo
    "not foo value"
  end

  def foo= val
    @foo = "still not foo value"
  end
end

