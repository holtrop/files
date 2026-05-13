#!/usr/bin/env ruby

require "open3"

SEARCH = %w[.git project.vim]
EDITOR = "nvim-qt"

def find_proj_root(path)
  path = File.expand_path(path)
  loop do
    dirname = File.dirname(path)
    if SEARCH.any? {|s| File.exist?(File.join(dirname, s))}
      if dirname =~ %r{([^/]+)/([^/]+)/*$}
        pretty_name = "#{$2}(#{$1})"
      else
        pretty_name = File.basename(dirname)
      end
      stdout, stderr, status = Open3.capture3("xxh32sum", stdin_data: dirname)
      socket_name = stdout.sub(/\s.*/m, "")
      return [socket_name, pretty_name]
    end
    path = dirname
    if path == "/"
      return nil
    end
  end

  nil
end

def run_dir
  ENV["XDG_RUNTIME_DIR"] || "/tmp"
end

def launch(socket_path, pretty_name, path)
  if File.exist?(socket_path)
    # Server running, send it remote command
    system("nvim", "--headless", "--server", socket_path, "--remote-tab-silent", path)
  else
    # Start the server
    $started_server = true
    system(EDITOR, path, "--", "--listen", socket_path)
  end
end

if ARGV.empty?
  exec(EDITOR)
else
  ARGV.each_with_index do |path, i|
    socket_name, pretty_name = find_proj_root(path)
    socket_path = "#{run_dir}/e-#{socket_name}.sock"
    if i == 1
      20.times do
        sleep(0.01)
        break if File.exist?(socket_path)
      end
    end
    launch(socket_path, pretty_name, path)
    if i == ARGV.length - 1
      # This is the last argument. If the server was not started for any paths,
      # then request that the window take focus.
      unless $server_started
        system("nvim", "--headless", "--server", socket_path, "--remote-send", "<Esc>:call GuiForeground()<CR><C-l>")
      end
    end
  end
end
