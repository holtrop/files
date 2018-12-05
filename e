#!/usr/bin/env ruby

# Use HighContrast GTK2 theme for gvim.
ENV["GTK2_RC_FILES"] = "/usr/share/themes/HighContrast/gtk-2.0/gtkrc"

def get_server_name(path)
  if path
    path = File.expand_path(path)
    while path != "/"
      dirname = File.dirname(path)
      if File.exists?(File.join(dirname, "project.vim"))
        if dirname =~ %r{([^/]+)/([^/]+)/*$}
          sn = "#{$2}(#{$1})"
        else
          sn = File.basename(dirname)
        end
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
