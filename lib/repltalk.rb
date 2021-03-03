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

class User
	attr_reader :id, :username, :name, :pfp, :bio, :cycles, :is_hacker, :roles, :languages

	def initialize(user)
		@id = user["id"]
		@username = user["username"]
		@name = user["fullName"]
		@pfp = user["image"]
		@bio = user["bio"]
		@cycles = user["karma"]
		@is_hacker = user["isHacker"]
		@roles = user["roles"].map { |role| Role.new(role) }
		@languages = user["languages"].map { |lang| Language.new(lang) }
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

	def get_user(name)
		u = graphql(
			"userByUsername",
			Queries.get_user,
			username: name
		)
		User.new(u["user"])
	end

	def get_user_by_id(id)
		u = graphql(
			"user",
			Queries.get_user_by_id,
			user_id: id
		)
		User.new(u["user"])
	end


	private

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
end