require 'Win32API'

class Game
  
  attr_accessor :x, :y

  def initialize( options = {} )
    @draw_mode = options[:draw_mode]
    @character = '*'
    @getCursorPos = Win32API.new("user32", "GetCursorPos", ['P'], 'V')
    @lpPoint = " " * 8
    @resolution = [1280,960]
    @window = [80,24]
    @field = Array.new( @window[1] ){ Array.new( @window[0] ){ ' ' } }
    fill_field
    @x, @y = 0, 0
    @last_x, @last_y = 0, 0
  end
  
  def fill_field
    @field[1][1] = 'i'
    @field[22][1] = 'c'
    @field[1][78] = 'd'
    @field[22][78] = 'e'
    @field[11][78] = 'q'
  end

  def clear_field
    @field.collect!{ |line| line.collect{ ' ' } }
    fill_field
  end

  def get_cursor_pos
    @getCursorPos.Call(@lpPoint)
    @lpPoint.unpack("LL").collect{ |e| e+1 }
  end

  def res_to_win( point )
    result = []
    [0,1].each do |axis|
      result.push point[axis].to_f / @resolution[axis] * @window[axis]
    end
    result
  end

  def update_field
    if @last_x != @x or @last_y != @y
      @field[@last_y-1][@last_x-1] = ' ' unless @draw_mode
      fill_field
      case @field[@y-1][@x-1]
        when 'i' then @character = @character == '*' ? '@' : '*'
        when 'c' then clear_field
        when 'd' then @draw_mode = true
        when 'e' then @draw_mode = false
        when 'q' then exit
      end
      @field[@y-1][@x-1] = @character
      @last_x, @last_y = @x, @y
    end
  end

  def print_field
    system('cls')
    @field.each{ |line| print line.join }
  end
  
  def step
    @x, @y = res_to_win get_cursor_pos
    update_field
    print_field
  end
  
  def print_xy
    puts "x: #{'%4d' % @x}, y: #{'%4d' % @y}"
  end

end

game = Game.new( :draw_mode => false )

loop do
  game.step
end