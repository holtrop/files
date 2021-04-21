#!/usr/bin/env ruby

require "set"
require "net/http"
require "json"

SERVER_URL = "https://git.jholtrop.com"
MIGRATE_API = "/api/v1/repos/migrate"
# Go to https://git.jholtrop.com/user/settings/applications to add a token.
TOKEN = File.read("token").chomp
USERNAME = "josh"
EXCLUDE = Set[*%w[gitolite-admin]]
CLONE_URL_BASE = "git://holtrop.mooo.com"

def read_gitolite_repos
  gitolite_conf = File.read("../gitolite-admin/conf/gitolite.conf")
  repo = nil
  gitolite_conf.each_line.reduce([]) do |result, line|
    if line =~ /^repo (\S+)/
      repo_name = $1
      if EXCLUDE.include?(repo_name)
        repo = nil
      else
        repo = {}
        repo[:oldname] = repo_name
        repo[:name] = File.basename(repo_name)
        result << repo
      end
    end
    if line =~ /^\s*config gitweb\.description\s*=\s*(\S.+)$/
      description = $1
      if repo
        repo[:description] = description
      end
    end
    result
  end
end

def check_unique_names(gitolite_repos)
  names = Set.new
  gitolite_repos.each do |repo|
    if names.include?(repo[:name])
      raise "duplicate repo name: #{repo[:name]}"
      names << repo[:name]
    end
  end
end

def migrate_repo(repo)
  puts "Migrating #{repo[:name]}..."
  clone_url = "#{CLONE_URL_BASE}/#{repo[:oldname]}.git"
  uri = URI("#{SERVER_URL}/#{MIGRATE_API}")
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "token #{TOKEN}"
    request.set_form_data(
      "clone_addr" => clone_url,
      "repo_name" => repo[:name],
      "description" => repo[:description],
      "repo_owner" => USERNAME,
      "mirror" => "false",
      "private" => "true",
    )
    response = http.request(request)
    case response
    when Net::HTTPSuccess
    else
      puts response.body
      response.value
    end
  end
end

# Change from private to public to get git-daemon-export-ok to appear.
def make_public(repo)
  uri = URI("#{SERVER_URL}/api/v1/repos/#{USERNAME}/#{repo[:name]}")
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Patch.new(uri)
    request["Authorization"] = "token #{TOKEN}"
    request.content_type = "application/json"
    request.body = JSON.dump("private" => false)
    response = http.request(request)
    case response
    when Net::HTTPSuccess
    else
      puts response.body
      response.value
    end
  end
end

def add_topic(repo, topic)
  uri = URI("#{SERVER_URL}/api/v1/repos/#{USERNAME}/#{repo[:name]}/topics/#{topic}")
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Put.new(uri)
    request["Authorization"] = "token #{TOKEN}"
    response = http.request(request)
    case response
    when Net::HTTPSuccess
    else
      puts response.body
      response.value
    end
  end
end

def process_all(repos)
  repos.each do |repo|
    migrate_repo(repo)
    make_public(repo)
    if repo[:oldname] =~ %r{^(\S+)/}
      topic = $1
      topic = {
        "exp" => "experimental",
        "ref" => "reference",
        "util" => "utility",
      }[topic] || topic
      add_topic(repo, topic)
    end
  end
end

gitolite_repos = read_gitolite_repos
check_unique_names(gitolite_repos)

# Just test with one for now
#gitolite_repos.select! do |repo|
#  %w[exp/jes].include?(repo[:oldname])
#end
#gitolite_repos = [{
#  name: "rscons-test",
#  description: "test rscons import",
#  oldname: "rscons",
#}]

process_all(gitolite_repos)
