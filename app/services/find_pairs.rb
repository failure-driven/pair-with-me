# frozen_string_literal: true

# usage
# bin/rails runner 'FindPairs.new.process(ARGV.join())' saramic

class FindPairs
  BASE_TMP_DIR = "tmp/pair_repositories"

  module GitHub
    class Api
      attr_accessor :nickname

      def initialize(nickname: nil, cache_dir: "tmp/fetch_cache")
        @nickname = nickname
        @cache_dir = cache_dir
      end

      def search(term)
        results = fetch_json(uri_for_search_term(term))
        # TODO: results can be nil if we get throttled
        return [] unless results["items"]

        # TODO: new from hash to save on API query
        results["items"]
          .find_all { |item| item["type"] == "User" }
          .map { |item| GitHub::Api.new(nickname: item["login"], cache_dir: @cache_dir) }
      end

      def user_deets
        @user_deets ||= fetch_json(
          uri_for_user_deets,
        ).tap do |user_json|
          return {} unless user_json
          user_json.slice(*%w[login id repos_url type email name twitter_username])
        end
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

      def uri_for_search_term(term)
        URI.parse("https://api.github.com/search/users").tap do |uri|
          uri.query = "q=#{term}" # TODO: HTML encode?
        end
      end

      def fetch_json(uri)
        if @cache_dir
          uri_filename = uri
            .to_s
            .gsub(%r{^/}, "")
            .tr(":", "-")
            .tr("/", "-")
            .tr("?", "-")
            .tr("&", "-")
            .tr("=", "-")
            .tr(" ", "-")
            .gsub(/$/, ".json")
          cache_key = File.join(@cache_dir, uri_filename)

          return JSON.parse(File.read(cache_key)) if File.exist? cache_key
        end

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.get(uri.request_uri)
        sleep 0.5 # don't flood the API
        json_response = JSON.parse(response.body)
        # TODO: deal with ERROR 403: rate limit exceeded.
        if response.is_a?(Net::HTTPSuccess)
          sleep 0.5
        end
        if @cache_dir
          if response.is_a?(Net::HTTPSuccess)
            File.binwrite(cache_key, json_response.to_json)
          end
        end
        json_response
      rescue => e
        puts "ERROR" # rubocop:disable Rails/Output
        puts e.message # rubocop:disable Rails/Output
        puts uri # rubocop:disable Rails/Output
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

      @git = if File.exist? @git_dir
        Git.open(@git_dir)
        # @git.pull # TODO: don't need to pull when running a second time
        # TODO: sort out which branch to pull master is default but will need to be changed to main often
      else
        Git.clone(@remote_url, @git_dir)
      end
      @git
    end
  end

  def process(login, debug: -> { Kernel.puts(_1) }, options: {})
    base_tmp_dir = options[:base_tmp_dir] || BASE_TMP_DIR
    fetch_cache_dir = options[:fetch_cache_dir] || "tmp/fetch_cache"
    github_api = GitHub::Api.new(nickname: login, cache_dir: fetch_cache_dir)

    debug.call(github_api.user_deets) # TODO: replace with find or creae user

    return "user not found" if github_api.user_deets == {}

    # if type == "User" vs type == "Organization" like failure-driven
    if github_api.user_deets["type"] == "User"
      user = User.find_or_create_by(
        uid: github_api.user_deets["id"],
        provider: :github,
        name: github_api.user_deets["name"],
        username: github_api.user_deets["login"],
      )
      user.password = options["password"] if user.password.blank? && options.key?("password")
      if user.email.blank?
        user.email = format(
          "%<id>s+%<login>s@users.noreply.github.com",
          id: github_api.user_deets["id"],
          login: github_api.user_deets["login"],
        )
      end
      user.save!
    end

    all_repo_urls = github_api.all_repo_urls

    all_repo_urls.each do |remote_url|
      git_remote = GitRemote.new(remote_url, Rails.root.join(base_tmp_dir))

      # TODO: Create pairs
      commits = git_remote.process
      debug.call(commits)
      commits.each do |commit|
        author_email = commit.dig(:author, :email)
        username = author_email[/([^@]+)@users.noreply.github.com/, 1]
        # username = commit.dig(:author, :email)[/(\d+)\+([^\@]+)\@users.noreply.github.com/, 2]

        if username
          pp github_api.search(username).map(&:nickname) # rubocop:disable Rails/Output
        else
          pp github_api.search(commit.dig(:author, :name)).map(&:nickname) # rubocop:disable Rails/Output
          pp github_api.search(commit.dig(:author, :email)).map(&:nickname) # rubocop:disable Rails/Output
        end

        co_author_email = commit.dig(:co_author, :email)
        username = co_author_email[/([^@]+)@users.noreply.github.com/, 1]
        if username
          pp github_api.search(username).map(&:nickname) # rubocop:disable Rails/Output
        else
          pp github_api.search(commit.dig(:co_author, :name)).map(&:nickname) # rubocop:disable Rails/Output
          pp github_api.search(commit.dig(:co_author, :email)).map(&:nickname) # rubocop:disable Rails/Output
        end

        author = nil
        co_author = nil
        if github_api.user_deets["name"] == commit.dig(:author, :name)
          author = User.find_by(
            uid: github_api.user_deets["id"],
            provider: :github,
            name: github_api.user_deets["name"],
            username: github_api.user_deets["login"],
          )
        end
        # NOTE: not tested
        author_email_left = commit.dig(:author, :email).sub(/@.*$/, "")
        if !author &&
            github_api.search(commit.dig(:author, :name)).map(&:nickname).grep(/#{author_email_left}/).length == 1
          nickname = github_api.search(commit.dig(:author, :name)).map(&:nickname)
            .grep(author_email_left).first
          author = User.find_by(username: nickname)
        end
        if !author &&
            github_api.search(commit.dig(:author, :name)).map(&:nickname).length == 1
          nickname = github_api.search(commit.dig(:author, :name)).map(&:nickname).first
          author = User.find_by(username: nickname)
        end
        email_left = commit.dig(:co_author, :email).sub(/@.*$/, "")
        if github_api.search(commit.dig(:co_author, :name)).map(&:nickname).length == 1 ||
            github_api.search(commit.dig(:co_author, :name)).map(&:nickname).grep(/#{email_left}/).length == 1

          nickname = github_api.search(commit.dig(:co_author, :name)).map(&:nickname).first
          # NOTE: not tested
          # email_left@example.com found in [email_left, other]
          nickname ||= github_api.search(commit.dig(:co_author, :name)).map(&:nickname)
            .grep(email_left).first
          co_author_github_api = GitHub::Api.new(nickname: nickname, cache_dir: fetch_cache_dir)
          break if co_author_github_api.user_deets == {}
          co_author = User.find_or_create_by(
            uid: co_author_github_api.user_deets["id"],
            provider: :github,
            name: co_author_github_api.user_deets["name"] || "username: #{co_author_github_api.user_deets["login"]}",
            username: co_author_github_api.user_deets["login"],
          )
          co_author.password ||= SecureRandom.hex(32)
          if co_author.email.blank?
            co_author.email = commit.dig(:co_author, :email)
          end
          co_author.save!
        end

        # if !co_author
        #   puts "enter a github username:"
        #   username = $stdin.readline
        #   puts username
        #   exit
        # end

        # NOTE: untested below
        if !co_author && github_api.search(commit.dig(:co_author, :email)).map(&:nickname).length == 1
          nickname = github_api.search(commit.dig(:co_author, :email)).map(&:nickname).first
          co_author_github_api = GitHub::Api.new(nickname: nickname, cache_dir: fetch_cache_dir)
          co_author = User.find_or_create_by(
            uid: co_author_github_api.user_deets["id"],
            provider: :github,
            name: co_author_github_api.user_deets["name"],
            username: co_author_github_api.user_deets["login"],
          )
          co_author.password ||= SecureRandom.hex(32)
          if co_author.email.blank?
            co_author.email = commit.dig(:co_author, :email)
          end
          begin
            co_author.save!
          rescue => e
            Rails.logger.debug "\033[0;31m"
            Rails.logger.debug { "failed to save #{co_author.attributes}" }
            Rails.logger.debug { "error: #{e.message}" }
            Rails.logger.debug { "with: #{co_author.errors.full_messages}" }
            Rails.logger.debug "\033[0m"
          end
        end
        # binding.pry unless author

        if author && co_author
          Pair.find_or_create_by!(author: author, co_author: co_author)
        end
      end
    end
  end
end
