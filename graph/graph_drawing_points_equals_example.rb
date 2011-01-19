require 'graph_drawing.rb'

include GraphDrawing

x_array = (1..14).to_a
y_array = [4.3,5,5.5,6.25,6.5,6.6,6.3,5.2,4,2.5,1.8,1.3,1,1.5]

pointgraph = Graph.new :x => x_array, :y => y_array, :show_points => true

angles = [1,4,6,7,10,12,13,14]
equals = lambda do |x|
  result = 0
  angles.each_index do |i|
    next if i == angles.size-1
    if ( angles[i]..angles[i+1] ).include?( x )
      target = [i,i+1].map{ |e| x_array.index( angles[e] ) }
      x1, x2, y1, y2 = x_array[target[0]], x_array[target[1]], y_array[target[0]], y_array[target[1]]
      k = (y2-y1)/(x2-x1)
      b = y2 - (y2-y1)*x2/(x2-x1)
      result = k*x+b
    end
  end
  result
end

equalsgraph = Graph.new :function => equals, :range => 1..14

drawing = Magick::Draw.new
drawing.prepare_graph :graph => equalsgraph
drawing.stroke_width 2
drawing.stroke_color 'red'
drawing.draw_graph equalsgraph
drawing.stroke_width 1
drawing.stroke_color 'black'
drawing.draw_graph pointgraph
graph_image(drawing).write('graph.jpg')