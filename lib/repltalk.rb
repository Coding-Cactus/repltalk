require "http"
require "json"
require_relative "queries"

class User
	attr_reader :id, :username, :name, :pfp, :bio, :cycles, :is_hacker, :roles

	def initialize(user)
		@id = user["id"]
		@username = user["username"]
		@name = user["fullName"]
		@pfp = user["image"]
		@bio = user["bio"]
		@cycles = user["karma"]
		@is_hacker = user["isHacker"]
		@roles = user["roles"] # will do something proper with them eventually
	end
end

class Client
	attr_accessor :sid

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