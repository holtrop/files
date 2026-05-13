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

if ARGV.empty?
  exec(EDITOR)
else
  socket_name, pretty_name = find_proj_root(ARGV[0])
  if socket_name
    socket_path = "#{run_dir}/e-#{socket_name}.sock"
    if File.exist?(socket_path)
      tabedits = ARGV.map do |path|
        path = File.expand_path(path).gsub(" ", "\\ ")
        %[:tabe #{path}<CR>]
      end.join
      puts tabedits
      exec("nvim", "--headless", "--server", socket_path, "--remote-send", "<Esc>#{tabedits}:call GuiForeground()<CR><C-l>")
    else
      exec(EDITOR, "--", "--listen", socket_path, "-p", *ARGV)
    end
  else
    exec(EDITOR, "--", "-p", *ARGV)
  end
end
