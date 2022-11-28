# frozen_string_literal: true

# usage
# bin/rails runner 'FindPairs.new.process(ARGV.join())' saramic

class FindPairs
  BASE_TMP_DIR = "tmp/pair_repositories"

  module GitHub
    class Api
      def initialize(nickname:)
        @nickname = nickname
      end

      def user_deets
        @user_deets ||= fetch_json(
          uri_for_user_deets,
        ).slice(*%w[login id repos_url type email twitter_username])
      end

      def all_repo_urls
        return @all_repo_urls if @all_repo_urls

        @all_repo_urls = []
        page = 1
        git_urls = nil
        while git_urls.nil? || !git_urls.empty?
          git_urls = fetch_json(uri_for_repos_page(page)).map { |repo| repo.dig("ssh_url") }
          @all_repo_urls += git_urls
          page += 1
        end
        @all_repo_urls
      end

      private

      def uri_for_user_deets = URI.parse("https://api.github.com/users/#{@nickname}")

      def uri_for_repos_page(page)
        URI.parse(user_deets["repos_url"]).tap do |uri|
          uri.query = "page=#{page}" if page > 1
        end
      end

      def fetch_json(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.get(uri.request_uri)
        JSON.parse(response.body)
      end
    end
  end

  class GitRemote
    def initialize(remote_url, base_path)
      @debug = -> { Kernel.puts(_1) }
      @remote_url = remote_url
      dir = @remote_url[/.*:(.*).git$/, 1]
      @git_dir = File.join(base_path, dir).to_s
    end

    def process
      git
        .log
        .find_all { |log| log.message =~ /Co-authored-by:/m }
        .map { |log|
          extract_authors_from_log(log)
        }.flatten
    rescue Git::GitExecuteError => e
      @debug.call(e.message)
      @debug.call("for #{@remote_url}")
    end

    private

    def extract_authors_from_log(log)
      log
        .message
        .split("\n")
        .grep(/Co-authored-by:/)
        .map { |line| process_line(log, line) }
    end

    def process_line(log, line)
      matches = /Co-authored-by: (.*) <(.*)>$/.match(line)
      {
        sha: log.sha,
        remote_url: git.remote.url,
        time: log.date.iso8601,
        author: {
          name: log.author.name,
          email: log.author.email,
        },
        co_author: {
          name: matches[1],
          email: matches[2],
        },
      }
    end

    def git
      return @git if @git

      if File.exist? @git_dir
        @git = Git.open(@git_dir)
        @git.pull
      else
        @git = Git.clone(@remote_url, @git_dir)
      end
      @git
    end
  end

  def process(login, debug = -> { Kernel.puts(_1) })
    github_api = GitHub::Api.new(nickname: login)

    debug.call(github_api.user_deets) # TODO: replace with find or creae user
    # if type == "User" vs type == "Organization" like failure-driven

    all_repo_urls = github_api.all_repo_urls

    all_repo_urls.each do |remote_url|
      git_remote = GitRemote.new(remote_url, Rails.root)

      # TODO: Create pairs
      debug.call(git_remote.process)
    end
  end
end
