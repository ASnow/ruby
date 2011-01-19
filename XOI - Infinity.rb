$KCODE="utf-8"

xoi_maxplayers=2
$xoi_screen=26
$xoi_textwidth=29

def xoi_input(min,max)
  result=gets.to_i
  if result<min or result>max then puts ' '*$xoi_screen+'      Invalid value!!!'; gets; exit end
  return result
end

puts
puts ' '*$xoi_screen+'    |= = = = = = = = = =|    '
puts ' '*$xoi_screen+'    |     X - O - I     |    '
puts ' '*$xoi_screen+'    |  I n f i n i t y  |    '
puts ' '*$xoi_screen+'    |= = = = = = = = = =|    '
puts
puts ' '*$xoi_screen+'       WELCOME TO XOI!       '
puts
puts ' '*$xoi_screen+'    Please, select battle:   '
puts ' '*$xoi_screen+'   1.  Player  vs. Computer  '
puts ' '*$xoi_screen+'   2.  Player  vs.  Player   '
puts ' '*$xoi_screen+'   3. Computer vs. Computer  '
print ' '*$xoi_screen+'        Your choice: '
xoi_mode=xoi_input(1,3)
print ' '*$xoi_screen+' Select xoi size (default 9): '
xoi_size=xoi_input(1,99)
print ' '*$xoi_screen+'Select win number (default 5): '
xoi_winnum=xoi_input(3,99)
puts
puts ' '*$xoi_screen+'      Prepare to fight!      '
puts
puts ' '*$xoi_screen+'   /*Press enter, please*/   '
print ' '*$xoi_screen+' '*($xoi_textwidth/2)
xoi_options=gets
puts
puts
puts
puts
puts
puts ' '*$xoi_screen+'    LET THE BATTLE BEGIN!    '
puts
puts
puts
puts
puts

xoi_thinking = xoi_options.include?('t') ? false : true
xoi_loging = xoi_options.include?('l') ? true : false
xoi_errorlog = xoi_options.include?('e') ? true : false
$xoi_debugmode = xoi_options.include?('d') ? true : false

srand

$stdout=File.new("log.txt",'w') if xoi_loging
$stderr=File.new("errors.txt",'w') if xoi_errorlog

class Array
  def xoi_onediagonal(xoi_x,xoi_y)
    if xoi_x+xoi_y<self.size then
      Array.new(xoi_x+xoi_y+1){|t|self[xoi_x+xoi_y-t][t]}
    else
      Array.new(self.size*2-xoi_x-xoi_y-1){|t|self[self.size-t-1][xoi_x+xoi_y-self.size+1+t]}
    end
  end
  def xoi_alldiagonal
    Array.new(self.size*2-1){|n|
      if n<self.size then
	Array.new(n+1){|t|self[n-t][t]}
      else
	Array.new(self.size*2-n-1){|t|self[self.size-t-1][n-self.size+1+t]}
      end
    }
  end
  def xoi_mirror
    Array.new(self.size){|n|Array.new(self.size){|t|self[n][self.size-t-1]}}
  end
  def xoi_scan(xoi_player)
    p self if $xoi_debugmode
    temp=self.map{|t|t==xoi_player ? xoi_player : 0}.join.split('0').max
    return temp.class==String ? temp.size : 0
  end
  def xoi_dscan?(xoi_num,xoi_player)
    self.each{ |e| return true if e.xoi_scan(xoi_player)>=xoi_num}
    false
  end
  def xoi_fscan?(xoi_num,xoi_player)
    return true if self.xoi_dscan?(xoi_num,xoi_player)
    return true if self.transpose.xoi_dscan?(xoi_num,xoi_player)
    return true if self.xoi_alldiagonal.xoi_dscan?(xoi_num,xoi_player)
    return true if self.xoi_mirror.xoi_alldiagonal.xoi_dscan?(xoi_num,xoi_player)
    false
  end
  def xoi_pscan(xoi_player,xoi_x,xoi_y)
    return [0] if not self[xoi_y][xoi_x]==0
    temp=Array.new(self.size){|y|Array.new(self.size){|x| (x==xoi_x and y==xoi_y) ? '@' : self[y][x] }}
    result=[temp[xoi_y].map{|t|t==xoi_player ? xoi_player : t=='@' ? '@' : 0}.join.split('0').find{|e|e.include?('@')}.size,\
               temp.transpose[xoi_x].map{|t|t==xoi_player ? xoi_player : t=='@' ? '@' : 0}.join.split('0').find{|e|e.include?('@')}.size,\
	       temp.xoi_onediagonal(xoi_x,xoi_y).map{|t|t==xoi_player ? xoi_player : t=='@' ? '@' : 0}.join.split('0').find{|e|e.include?('@')}.size,\
	       temp.xoi_mirror.xoi_onediagonal(self.size-xoi_x-1,xoi_y).map{|t|t==xoi_player ? xoi_player : t=='@' ? '@' : 0}.join.split('0').find{|e|e.include?('@')}.size]
    if $xoi_debugmode then result=[temp[xoi_y],temp.transpose[xoi_x],temp.xoi_onediagonal(xoi_x,xoi_y),temp.xoi_mirror.xoi_onediagonal(self.size-xoi_x-1,xoi_y)] end
    return result
  end
  def xoi_show
    puts ' '*(self.size<10 ? $xoi_screen : 0)+' '*(($xoi_textwidth-self.size)/4-1)+(self.size<10 ? '  ' : '    ')+(self.size<10 ? (1..self.size).to_a.join(' ') : (1..9).to_a.join('  ')+' 10 '+(11..self.size).to_a.join(' '))
    puts if self.size>9
    self.each_with_index{|e,n|
      puts(' '*(self.size<10 ? $xoi_screen : 0)+' '*(($xoi_textwidth-self.size)/4-1)+((self.size>=10 and n<9) ? ' ' : '')+(n+1).to_s+' '*(self.size/10+1)+e.join(' '*(self.size/10+1)).gsub('0','.').gsub('1','x').gsub('2','o'))
      puts if self.size>9
    }
    puts
  end
end

#xoi_pole2=Array.new(xoi_size){Array.new(xoi_size){rand(3)}}
#p xoi_pole2
#xoi_pole2.each_with_index{|e,n|puts(e.join(' '))}
#$xoi_debugmode=true
#p xoi_pole2.xoi_pscan(1,5,4)
#return

# Создаём поле
xoi_pole=Array.new(xoi_size){Array.new(xoi_size){0}}

# Выводим поле на экран
xoi_pole.xoi_show

# Устанавливаем, кто первый НЕ ходит, обнуляем счётчик ходов и устанавливаем максимум ходов
xoi_player=2
xoi_turns=0
xoi_maxturns=xoi_size**2

# Начинаем игру!
while true do
  # Ход иигрока
  if xoi_mode!=3 then
    xoi_player = xoi_player==1 ? 2 : 1
    puts ' '*$xoi_screen+'          PLAYER '+xoi_player.to_s+'!'
    puts 'Input coordinates...'
    print 'x: '; temp1=xoi_input(1,xoi_size)
    print 'y: '; temp2=xoi_input(1,xoi_size)
    xoi_turn=[temp1-1,temp2-1].reverse
    if not xoi_pole[xoi_turn[0]][xoi_turn[1]]==0 then puts ' '*$xoi_screen+'Hey, what the?!. Go away!!!'; gets; return end
    puts
    puts 'Your turn is '+[xoi_turn[1]+1,xoi_turn[0]+1].join(',')+'.'
    xoi_pole[xoi_turn[0]][xoi_turn[1]]=xoi_player
    puts
    xoi_pole.xoi_show
    # Проверяем, не выйграл ли игрок
    (1..xoi_maxplayers).each{|p|
      if xoi_pole.xoi_fscan?(xoi_winnum,p) then
        puts
	puts ' '*$xoi_screen+'       Player '+p.to_s+' WINS!!!'
	puts
	print ' '*$xoi_screen+' '*($xoi_textwidth/2)
	gets
	return p
      end
    }
  end

  # Ход компьютера
  if xoi_mode!=2 then
    xoi_player = xoi_player==1 ? 2 : 1
    puts ' '*$xoi_screen+'          PLAYER '+xoi_player.to_s+'!'
    puts 'Computer thinking...'
    # Рандомный ход
    xoi_turn=[rand(xoi_pole.size),rand(xoi_pole.size)]
    xoi_randomturn=xoi_turn
    xoi_priority=xoi_winnum
    p 'I like turn '+[xoi_turn[1]+1,xoi_turn[0]+1].join(',')+'!' if xoi_thinking
    # Проверяем, не стоит ли там что
    while not xoi_pole[xoi_turn[0]][xoi_turn[1]]==0 do
      p 'But i can\'t... :(' if xoi_thinking
      xoi_turn=[rand(xoi_pole.size),rand(xoi_pole.size)]
      p 'I like turn '+[xoi_turn[1]+1,xoi_turn[0]+1].join(',')+'!' if xoi_thinking
    end
    p 'But now i will think...' if xoi_thinking
    # Проверяем возможность победы
    (2..xoi_winnum).each{|n|
      xoi_pole.each_with_index{|ey,y|
        ey.each_with_index{|ex,x|
          p 'Let\'s see '+[y+1,x+1].join(',') if xoi_thinking==2
          if xoi_pole.xoi_pscan(xoi_player,y,x).max==n and (xoi_winnum-n)*2<xoi_priority then
            xoi_turn=[x,y]
            xoi_priority=(xoi_winnum-n)*2
            p 'Yes, it is! Priority of ['+[y+1,x+1].join(',')+'] is '+xoi_priority.to_s+'! I can set '+xoi_pole.xoi_pscan(xoi_player,y,x).max.to_s+' signs!' if xoi_thinking
            p xoi_pole.xoi_pscan(xoi_player,y,x) if $xoi_debugmode
          end
        }
      }
    }
    # Проверяем возможность поражения
    ((xoi_winnum-2)..xoi_winnum).each{|n|
      xoi_pole.each_with_index{|ey,y|
        ey.each_with_index{|ex,x|
          p 'And what about defeat in '+[y+1,x+1].join(',')+'?..' if xoi_thinking==2
	  flag = n==xoi_winnum ? xoi_pole.xoi_pscan(xoi_player==1 ? 2 : 1,y,x).max>=n : xoi_pole.xoi_pscan(xoi_player==1 ? 2 : 1,y,x).max==n
          if flag and (xoi_winnum-n)*2+1<xoi_priority then
	    xoi_turn=[x,y]
	    xoi_priority=(xoi_winnum-n)*2+1
            p 'Oh, it\'s dangerous! Priority of ['+[y+1,x+1].join(',')+'] is '+xoi_priority.to_s+'! It can be '+xoi_pole.xoi_pscan(xoi_player==1 ? 2 : 1,y,x).max.to_s+' signs!' if xoi_thinking
            p xoi_pole.xoi_pscan(xoi_player==1 ? 2 : 1,y,x) if $xoi_debugmode
          end
        }
      }
    }
    p 'All OK there!' if xoi_turn==xoi_randomturn and xoi_thinking
    puts 'My turn is '+[xoi_turn[1]+1,xoi_turn[0]+1].join(',')+'!'
    xoi_pole[xoi_turn[0]][xoi_turn[1]]=xoi_player
    # Выводим поле на экран
    xoi_pole.xoi_show
    # Проверяем, не выйграл ли компьютер
    (1..xoi_maxplayers).each{|p|
      if xoi_pole.xoi_fscan?(xoi_winnum,p) then
        puts
	puts ' '*$xoi_screen+'       Player '+p.to_s+' WINS!!!'
	puts
	print ' '*$xoi_screen+' '*($xoi_textwidth/2)
	gets
	exit
      end
    }
  end
  # Проверяем, не случилась ли ничья
  xoi_turns+=1
  if xoi_turns==xoi_maxturns then puts ' '*$xoi_screen+'           DRAW!'; gets; exit end
end