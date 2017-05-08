#!/usr/bin/env ruby

def get_server_name(path)
  if path
    path = File.expand_path(path)
    while path != "/"
      dirname = File.dirname(path)
      if File.exists?(File.join(dirname, "project.vim"))
        sn = File.basename(dirname) + "1"
        return sn
      end
      path = dirname
    end
  end

  return "GVIM"
end

def server_running?(server_name)
  `gvim --serverlist`.lines.map(&:chomp).include?(server_name.upcase)
end

if ARGV.empty?
  server_name = get_server_name('local_file')
  exec("/usr/bin/gvim", "--servername", server_name, err: "/dev/null")
else
  ARGV.each_with_index do |path, i|
    server_name = get_server_name(path)
    sleep(0.2) if i > 0
    system("/usr/bin/gvim", "--servername", server_name, "--remote-tab-silent", path, err: "/dev/null")
  end
end
