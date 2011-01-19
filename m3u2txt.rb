for i in 0...Dir["*.m3u"].size
  $stdin = File.open(Dir["*.m3u"][i])
  $stdout = File.open(Dir["*.m3u"][i][0..-4]+"txt",'w')
  begin
    while true
      gets
      puts (gets.split(/EXTINF:\d{3},(.*)/mix).join)[1..-2]
    end
  rescue
  end
end