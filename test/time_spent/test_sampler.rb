require_relative '../test_helper'

class Sampler
  public_class_method :new
  public :render
end

class TestSampler < Minitest::Test
  def subject
    Sampler
  end

  def test_render
    subj = subject.new(Object.new, '')
    rendered = subj.render('Class: <%= @model.class %>')
    assert_equal 'Class: Object', rendered
  end
end
