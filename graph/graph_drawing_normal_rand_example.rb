require 'graph_drawing_IdealExceptMethodDefiningAndWordAsimptota.rb'

include GraphDrawing

module Math
  def self.normal_rand( x )
    1/sqrt(2*PI)*E**(-x**2/2)
  end
end

function = lambda{ |x| 1.2 * Math.normal_rand( 0.2 * x ) }

drawing = graph_drawing function, lambda{ |x| 0.065 }, :range => -30..30
drawing.draw_asimptota 10
drawing.draw_asimptota 20
graph_image(drawing).write('graph.jpg')