module GraphDrawing

  require 'rubygems'
  require 'rmagick'

  module VariablesControl
    #require 'rubygems'
    #require 'active_support'
    def make_instance_variables_with_full_access( hash, prefix = '', suffix = '' )
      hash.each do |key, value|
        name = prefix + key.to_s + suffix
        instance_variable_set( '@' + name, value )
        #define_method( name ){ instance_variable_get( '@' + name ) }
        #define_method( name + '=' ){ |value| instance_variable_set( '@' + name, value ) }
      end
    end
  end

  class Graph
    
    include VariablesControl
    
    attr_accessor :x, :y, :points, :show_points, :step # to delete step
    
    def initialize( user_options = {} )
      options = { :range => self.class.default_range, :step => self.class.default_step }
      options.update( user_options )
      make_instance_variables_with_full_access options
      from_function if @function
      from_points if @points
      prepare_points
    end
    
    def from_function
      @x = []
      @range.first.step @range.last, @step do |x| @x.push x end
      @y = @x.collect{ |x| @function.call( x ) }
    end
    
    def from_points
      @x, @y = [], []
      @points.each{ |pair| @x.push( pair.first ); @y.push( pair.last ) }
    end
    
    def prepare_points
      return @points = nil unless [@x, @y].all?{ |e| e.respond_to? 'size' } and @x.size == @y.size
      [@x, @y].each{ |array| array.collect{ |e| e.to_f } }
      @points = []
      @x.size.times do |i| @points.push( { :x => @x[i], :y => @y[i] } ) end
    end
    
    def range( axis, options = {} )
      return nil unless [@x, @y].all?{ |e| e.respond_to? 'min' and e.respond_to? 'max' }
      value = options[:value] || max(axis)
      options[:length] ? value - min(axis) : min(axis)..value
    end
    
    def values(axis, no_nil = false)
      result = instance_variable_get('@'+axis.to_s)
      result.reject{ |e| e.nil? } if no_nil
    end
    
    def min(axis)
      values(axis, :no_nil).min
    end
    
    def max(axis)
      values(axis, :no_nil).max
    end
    
    def self.default_range
      -10..10
    end
    
    def self.default_step
      0.1
    end
    
  end

  class Magick::Draw
    
    include VariablesControl
    
    attr_accessor :graph_prepared, :graph_size, :graph_margin, :graph_range_x # to delete all except prepared
    
    def draw_graph( graph, user_options = {} )
      user_options[:step] ||= graph.step
      user_options[:range_x] ||= graph.range(:x)
      user_options[:range_y] ||= graph.range(:y)
      prepare_graph( user_options ) unless @graph_prepared
      graph.points.size.times do |i|
        connect = true
        last_point = i == graph.points.size-1
        pixels = {}
        ( last_point ? [0] : [0, 1] ).each do |shift|
          y = graph.points[ i + shift ][ :y ]
          connect = false if y.nil? or y < @graph_range_y.first or y > @graph_range_y.last
          [:x, :y].each do |axis|
            pixels[ axis.to_s+(shift+1).to_s ] = graph_to_pixel( axis, graph.points[ i + shift ][ axis ] )
          end
        end
        line pixels['x1'], pixels['y1'], pixels['x2'], pixels['y2'] if connect and @graph_connections and not last_point
        circle pixels['x1'], pixels['y1'], pixels['x1'] + @graph_point_size, pixels['y1'] if graph.show_points
      end
    end
    
    def draw_asimptota( x )
      x = graph_to_pixel( :x, x )
      line x, @graph_margin, x, @graph_margin + @graph_size
    end
    
    def prepare_graph( user_options = {} )
      options = { :range => Graph.default_range, :step => Graph.default_step, :zero => true, :size => 460, :margin => 20, :padding => 20, :axes => true, :border => false, :limits => true, :connections => true, :points => false, :point_size => 2 }
      options.update( :range_x => user_options[:graph].range(:x), :range_y => user_options[:graph].range(:y) ) if user_options[:graph]
      options.update( user_options )
      make_instance_variables_with_full_access options, 'graph_'
      @graph_size_x ||= @graph_size
      @graph_size_y ||= @graph_size
      @graph_range_x ||= @graph_range
      @graph_range_y ||= @graph_range
      graph_include_zero if @graph_zero
      graph_draw_axes if @graph_axes
      graph_draw_border if @graph_border
      graph_draw_limits if @graph_limits
      @graph_prepared = true
    end
    
    def graph_to_pixel( axis, value )
      field = instance_variable_get('@graph_size_'+axis.to_s) or return nil
      field -= @graph_padding*2
      range = instance_variable_get('@graph_range_'+axis.to_s) or return nil
      diapason = value.to_f - range.first
      range = range.last - range.first
      ratio = diapason / range
      result = @graph_margin + @graph_padding + field * ratio
      result = @graph_size_y + @graph_margin*2 - result if axis == :y
      return result
    end
    
    def graph_include_zero
      @graph_range_x = 0..@graph_range_x.last if @graph_range_x.first > 0
      @graph_range_x = @graph_range_x.first..0 if @graph_range_x.last < 0
      @graph_range_y = 0..@graph_range_y.last if @graph_range_y.first > 0
      @graph_range_y = @graph_range_y.first..0 if @graph_range_y.last < 0
    end
    
    def graph_draw_axes
      [:x, :y].each do |axis|
        range = instance_variable_get('@graph_range_'+axis.to_s)
        next unless range.include? 0
        zero = graph_to_pixel( axis, 0 )
        boundary = @graph_margin + instance_variable_get('@graph_size_'+axis.to_s)
        case axis
          when :x then
            line zero, @graph_margin, zero, boundary
            line zero, @graph_margin, zero+@graph_padding/4, @graph_margin+@graph_padding/2
            line zero, @graph_margin, zero-@graph_padding/4, @graph_margin+@graph_padding/2
          when :y then
            line @graph_margin, zero, boundary, zero
            line boundary, zero, boundary-@graph_padding/2, zero+@graph_padding/4
            line boundary, zero, boundary-@graph_padding/2, zero-@graph_padding/4
        end
      end
    end
    
    def graph_draw_border
      x1, y1, x2, y2 = @graph_margin, @graph_margin, @graph_margin+@graph_size_x, @graph_margin+@graph_size_y
      line x1, y1, x2, y1
      line x2, y1, x2, y2
      line x2, y2, x1, y2
      line x1, y2, x1, y1
    end
    
    def graph_draw_limits
      letter_width = 8
      letter_height = 5
      [:x, :y].each do |axis|
        range = instance_variable_get('@graph_range_'+axis.to_s)
        [:first, :last].each do |direction|
          value = range.send(direction)
          string = '%.1f' % value
          coordinate = graph_to_pixel( axis, value )
          case axis
            when :x then text coordinate-letter_width, 2*@graph_margin+@graph_size_y-@graph_margin/letter_height, string
            when :y then text @graph_margin/letter_width, coordinate+letter_height, string
          end
        end
      end
    end
    
  end
  
  def graph_drawing(*functions)
    options = {}
    options = functions.pop if functions.last.class == Hash
    drawing = Magick::Draw.new
    drawing.draw_graph Graph.new( options.update( :function => functions.shift ) ), options
    for function in functions do
      drawing.draw_graph Graph.new( options.update( :function => function, :range => drawing.graph_range_x ) ), options
    end
    drawing
  end
  
  def graph_image(drawing)
    size = drawing.graph_size + drawing.graph_margin*2
    image = Magick::Image.new( size, size )
    drawing.draw image
    image
  end

  def graph(*functions)
    options = {}
    options = functions.pop if functions.last.class == Hash
    drawing = graph_drawing(*functions)
    image = graph_image(drawing)
    image.write( options[:filename] || 'graph.jpg' )
  end
  
  Parabola = lambda{ |x| x**2 }
  Hyperbola = lambda{ |x| x == 0 ? nil : 1/x }
  Sin = lambda{ |x| Math.sin(x) }
  Cos = lambda{ |x| Math.cos(x) }
  Exp = lambda{ |x| Math::E**x }
  Log = lambda{ |x| x > 0 ? Math.log(x) : nil }

end

=begin
  # Example:
  include GraphDrawing
  graph Parabola
=end