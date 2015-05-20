#!/usr/bin/env ruby

def get_server_name(path)
  if path
    path = File.expand_path(path)
    while path != "/"
      dirname = File.dirname(path)
      if File.exists?(File.join(dirname, "project.vim"))
        return File.basename(dirname)
      end
      path = dirname
    end
  end

  return "GVIM"
end

if ARGV.empty?
  exec("/usr/bin/gvim", "--servername", get_server_name(nil), err: "/dev/null")
else
  ARGV.each_with_index do |path, i|
    server_name = get_server_name(path)
    sleep(0.2) if i > 0
    system("/usr/bin/gvim", "--servername", server_name, "--remote-tab-silent", path, err: "/dev/null")
  end
end
