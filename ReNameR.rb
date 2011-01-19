puts "Input name whithout extension, where * = number:"
name = gets[0..-2].split("*")
Dir["*.{avi,srt}"].map{ |elem| File.rename(elem, name[0]+elem[/\d{1,3}/]+(name[1]!=nil ? name[1] : "")+File.extname(elem)) ; elem }