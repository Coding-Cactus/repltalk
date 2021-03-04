require "http"
require "json"
require_relative "queries"

class Role
	attr_reader :name, :key, :tagline

	def initialize(role)
		@name = role["name"]
		@key = role["key"]
		@tagline = role["tagline"]
	end

	def to_s
		@name
	end
end



class Organization
	attr_reader :id, :name

	def initialize(organization)
		@id = organization["id"]
		@name = organization["name"]
	end

	def to_s
		@name
	end
end



class Language
	attr_reader :id, :key, :name, :tagline, :icon

	def initialize(lang)
		@id = lang["id"]
		@key = lang["key"]
		@name = lang["displayName"]
		@tagline = lang["tagline"]
		@icon = lang["icon"]
	end

	def to_s
		@id
	end
end



class Repl
	attr_reader :id, :url, :title, :description, :language, :is_private, :is_always_on

	def initialize(repl)
		@id = repl["id"]
		@url = repl["url"]
		@title = repl["title"]
		@description = repl["description"]
		@language = Language.new(repl["lang"])

		@is_private = repl["isPrivate"]
		@is_always_on = repl["isAlwaysOn"]
	end

	def to_s
		@title
	end
end



class Board
	attr_reader :id, :name, :color

	def initialize(board)
		@id = board["id"]
		@name = board["name"]
		@color = board["color"]
	end

	def to_s
		@name
	end
end



class Comment
	attr_reader :id, :url, :author, :content, :vote_count, :can_vote, :has_voted

	def initialize(client, comment)
		@client = client

		@id = comment["id"]
		@url = comment["url"]
		@author = User.new(@client, comment["user"])
		@content = comment["body"]
		@vote_count = comment["voteCount"]

		@can_vote = comment["canVote"]
		@has_voted = comment["hasVoted"]
	end

	def to_s
		@content
	end
end



class Post
	attr_reader :id, :url, :repl, :board, :title, :author, :content, :preview, :timestamp, :vote_count, :comment_count, :can_vote, :has_voted, :is_answered, :is_answerable, :is_hidden, :is_pinned, :is_locked, :is_announcement

	def initialize(client, post)
		@client = client
		
		@id = post["id"]
		@url = post["url"]
		@title = post["title"]
		@content = post["body"]
		@preview = post["preview"]
		@timestamp = post["timeCreated"]

		@board = Board.new(post["board"])
		@author = User.new(@client, post["user"])
		@repl = post["repl"] == nil ? nil : Repl.new(post["repl"])

		@vote_count = post["voteCount"]
		@comment_count = post["commentCount"]

		@can_vote = post["canVote"]
		@has_voted = post["hasVoted"]

		@is_answered = post["isAnswered"]
		@is_answerable = post["isAnswerable"]

		@is_hidden = post["isHidden"]
		@is_pinned = post["isPinned"]
		@is_locked = post["isLocked"]
		@is_announcement = post["isAnnouncement"]
	end

	def to_s
		@title
	end
end



class User
	attr_reader :id, :username, :name, :pfp, :bio, :cycles, :is_hacker, :roles, :organization, :languages

	def initialize(client, user)
		@client = client

		@id = user["id"]
		@username = user["username"]
		@name = user["fullName"]
		@pfp = user["image"]
		@bio = user["bio"]
		@cycles = user["karma"]
		@is_hacker = user["isHacker"]
		@roles = user["roles"].map { |role| Role.new(role) }
		@organization = user["organization"] == nil ? nil : Organization.new(user["organization"])
		@languages = user["languages"].map { |lang| Language.new(lang) }
	end

	def get_posts(order: "new", count: nil, after: nil)
		p = @client.graphql(
			"ProfilePosts",
			Queries.get_user_posts,
			username: @username,
			order: order,
			count: count,
			after: after
		)
		posts = Array.new
		p["user"]["posts"]["items"].each { |post| posts << Post.new(@client, post) }
		posts
	end

	def get_comments(order: "new", count: nil, after: nil)
		c = @client.graphql(
			"ProfileComments",
			Queries.get_user_comments,
			username: @username,
			order: order,
			count: count,
			after: after
		)
		comments = Array.new
		c["user"]["comments"]["items"].each { |comment| comments << Comment.new(@client, comment) }
		comments
	end

	def to_s
		@username
	end
end



class Client
	attr_writer :sid

	def initialize(sid=nil)
		@sid = sid
	end

	def graphql(name, query, **variables)
		payload = {
			operationName: name,
			query: query,
			variables: variables.to_json
		}
		r  = HTTP
				.cookies(
					"connect.sid": @sid
				)
				.headers(
					referer: "https://repl.it/@CodingCactus/repltalk",
					"X-Requested-With": "ReplTalk"
				)
				.post(
					"https://repl.it/graphql", 
					form: payload
				)
		begin data = JSON.parse(r)
		rescue
			puts "\e[31mERROR\n#{r}\e[0m"
			return nil
		end
		data = data["data"] if data.include?("data")
		data
	end

	def get_user(name)
		u = graphql(
			"userByUsername",
			Queries.get_user,
			username: name
		)
		User.new(self, u["user"])
	end

	def get_user_by_id(id)
		u = graphql(
			"user",
			Queries.get_user_by_id,
			user_id: id
		)
		User.new(self, u["user"])
	end

	def get_post(id)
		p = graphql(
			"post",
			Queries.get_post,
			id: id
		)
		Post.new(self, p["post"])
	end
end