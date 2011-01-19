require 'rubygems'
require 'rmagick'
include Magick

class Draw
  
  attr_accessor :size, :range, :max_y, :scale, :points
  
  def coordinates
    line 0, @size/2, @size, @size/2
    line @size/2, 0, @size/2, @size
  end
  
  def x_value( x )
    @size*(x.to_f/iterations)
  end
  
  def y_value( y )
    @size/2-(@size/2)*(@points[y]/@max_y)
  end
  
  def iterations
    ((@range.last - @range.first)/@scale - 1).to_i
  end
  
  def iteration( x )
    (x.to_f - @range.first)/(@range.last - @range.first) * iterations
  end
  
  def function(proc)
    
    @points = []

    @range.first.step @range.last, @scale do |x|
      @points.push proc.call(x).to_f
    end

    unless @max_y
      @max_y = @points.max
      text 20, 20, '%.2f' % @max_y
    end
    
    iterations.times{ |i| line x_value(i), y_value(i), x_value(i+1), y_value(i+1) }
    
  end
  
  def asimptota( x )
    x = x_value( iteration( x ) )
    line x, 0, x, @size
  end

end

module Math

  def self.normal_rand( x )
    1/sqrt(2*PI)*E**(-x**2/2)
  end
  
end

drawing = Draw.new

drawing.size = 500
drawing.range = -100..100
drawing.scale = 1

image = Image.new( drawing.size, drawing.size )
drawing.coordinates

drawing.function lambda{ |x| 1.2 * Math.normal_rand( 0.2 * x ) }
drawing.function lambda{ |x| 0.1 }
drawing.asimptota 10
drawing.asimptota 20

drawing.draw image
image.write('graph.jpg')