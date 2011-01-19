$stdout = File.open("Tracklist.txt",'w')
puts Dir["*.mp3"].map{ |e| e.split("")[0] == "0" ? e[1..1]+"."+e[4..-5] : e[0..1]+"."+e[4..-5]}.join("\n")