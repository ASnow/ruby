class Planet
  @order = 'class instance variable'
  def initialize num
    @order = num
  end

  def test_class_eval_for_class
    self.class.class_eval{ @order }
  end

  def test_instance_eval_for_class
    self.class.instance_eval{ @order }
  end
  def test_method_def_class_eval
    # метод определяется в контексте класса Planet
    self.class.class_eval{ def has_live?; false; end }
  end
  def test_method_def_instance_eval_for_instance
    # метод определяется в контексте синглтон класса объекта self
    instance_eval{ def has_live?; 'Yes'; end }
  end
  def test_method_def_inline_for_instance
    # метод определяется в контексте класса Planet
    def has_live?; '+'; end
  end
  def test_method_def_instance_eval_for_class
    # метод определяется в контексте синглтон класса объекта Planet
    self.class.instance_eval{ def has_live?; 'It depends'; end }
  end

  instance_eval do
    # определяем метод в контексте синглтон класса объекта self. Здесь self - Planet
    def with_satellite;
      'Earth'
    end 
  end

  class_eval do
    # определяем метод в контексте класса Planet
    def with_satellite;
      'Mars'
    end 
  end
end
earth = Planet.new 3
mars = Planet.new 4
p mars.instance_eval{ @order } # 4
p mars.class_eval{ @order } # no method
p mars.module_eval{ @order } # no method
p earth.test_class_eval_for_class # class instance variable
p earth.test_instance_eval_for_class # class instance variable


mars.test_method_def_class_eval

p mars.has_live? # false
p earth.has_live? # false
p earth.class.has_live? # no method
p earth.singleton_class.has_live? # no method

earth.test_method_def_instance_eval_for_instance

p mars.has_live? # false
p earth.has_live? # 'Yes'
p earth.class.has_live? # no method
p earth.singleton_class.has_live? # no method

earth.test_method_def_inline_for_instance

p mars.has_live? # '+'
p earth.has_live? # 'Yes'
p earth.class.has_live? # no method
p earth.singleton_class.has_live? # no method


earth.test_method_def_instance_eval_for_class

p mars.has_live? # '+'
p earth.has_live? # 'Yes'
p earth.class.has_live? # 'It depends'
p earth.singleton_class.has_live? # 'It depends'
p Planet.singleton_methods.include? :has_live? # true


p mars.with_satellite # Mars
p Planet.with_satellite # Earth

#test_class_eval
