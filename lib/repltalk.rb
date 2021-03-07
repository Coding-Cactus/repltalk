require "http"
require "json"
require_relative "queries"

$BASE_URL = "https://repl.it"

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
	attr_reader :id, :name, :country, :postal_code, :state, :city, :timestamp

	def initialize(organization)
		@id = organization["id"]
		@name = organization["name"]
		@country = organization["country"]
		@postal_code = organization["postalCode"]
		@state = organization["state"]
		@city = organization["city"]
		@timestamp = organization["timeCreated"]
	end

	def to_s
		@name
	end
end



class Subscription
	attr_reader :id, :plan_id, :quantity, :timestamp

	def initialize(subscription)
		@id = subscription["id"]
		@plan_id = subscription["planId"]
		@quantity = subscription["quantity"]
		@timestamp = subscription["timeCreated"]
	end

	def to_s
		@plan_id
	end
end



class Language
	attr_reader :id, :key, :name, :tagline, :icon, :category

	def initialize(lang)
		@id = lang["id"]
		@key = lang["key"]
		@name = lang["displayName"]
		@tagline = lang["tagline"]
		@icon = lang["icon"]
		@category = lang["category"]
	end

	def to_s
		@id
	end
end



class ReplComment
	attr_reader :id, :content, :author, :repl, :replies

	def initialize(client, comment)
		@client = client

		@id = comment["id"]
		@content = comment["body"]
		@author = comment["user"] == nil ? "[deleted user]" : User.new(@client, comment["user"])
		@repl = Repl.new(@client, comment["repl"])
		@replies = comment["replies"] == nil ? nil : comment["replies"].map { |c| ReplComment.new(@client, c) }
	end

	def to_s
		@content
	end
end



class Repl
	attr_reader :id, :url, :title, :author, :description, :size, :language, :img_url, :origin_url, :is_private, :is_always_on

	def initialize(client, repl)
		@client = client

		@id = repl["id"]
		@url = $BASE_URL + repl["url"]
		@title = repl["title"]
		@author = User.new(@client, repl["user"])
		@description = repl["description"]
		@size = repl["size"]
		@language = Language.new(repl["lang"])
		@image_url = repl["imageUrl"]
		@origin_url = repl["origin"] == nil ? nil : $BASE_URL + repl["origin"]["url"]

		@is_private = repl["isPrivate"]
		@is_always_on = repl["isAlwaysOn"]
	end

	def get_forks(count: 100, after: nil)
		f = @client.graphql(
			"ReplViewForks",
			Queries.get_repl_forks,
			url: @url,
			count: count,
			after: after
		)
		f["repl"]["publicForks"]["items"].map { |repl| Repl.new(@client, repl) }
	end

	def get_comments(count: nil, after: nil)
		c = @client.graphql(
			"ReplViewComments",
			Queries.get_repl_comments,
			url: @url,
			count: count,
			after: after
		)
		c["repl"]["comments"]["items"].map { |comment| ReplComment.new(@client, comment) }
	end

	def to_s
		@title
	end
end



class Board
	attr_reader :id, :name, :color, :description

	def initialize(board)
		@id = board["id"]
		@name = board["name"]
		@color = board["color"]
		@description = board["description"]
	end

	def to_s
		@name
	end
end



class Comment
	attr_reader :id, :url, :author, :content, :post_id, :is_answer, :vote_count, :timestamp, :can_vote, :has_voted

	def initialize(client, comment)
		@client = client

		@id = comment["id"]
		@url = $BASE_URL + comment["url"]
		@author = comment["user"] == nil ? "[deleted user]" : User.new(@client, comment["user"])
		@content = comment["body"]
		@post_id = comment["post"]["id"]
		@is_answer = comment["isAnswer"]
		@vote_count = comment["voteCount"]
		@timestamp = comment["timeCreated"]

		@can_vote = comment["canVote"]
		@has_voted = comment["hasVoted"]
	end

	def get_post
		p = @client.graphql(
			"post",
			Queries.get_post,
			id: @post_id
		)
		Post.new(@client, p["post"])
	end

	def get_comments
		c = @client.graphql(
			"comment",
			Queries.get_comments_comments,
			id: @id
		)
		c["comment"]["comments"].map { |comment| Comment.new(@client, comment) }
	end

	def get_parent
		c = @client.graphql(
			"comment",
			Queries.get_parent_comment,
			id: @id
		)
		c["comment"]["parentComment"] == nil ? nil : Comment.new(@client, c["comment"]["parentComment"])
	end

	def create_comment(content)
		c = @client.graphql(
			"createComment",
			Mutations.create_comment,
			input: {
				postId: @post_id,
				commentId: @id,
				body: content
			}
		)
		Comment.new(@client, c["createComment"]["comment"])
	end

	def edit(content)
		c = @client.graphql(
			"updateComment",
			Mutations.edit_comment,
			input: {
				id: @id,
				body: content
			}
		)
		Comment.new(@client, c["updateComment"]["comment"])
	end

	def delete
		@client.graphql(
			"deleteComment",
			Mutations.delete_comment,
			id: @id
		)
		nil
	end

	def to_s
		@content
	end
end



class Post
	attr_reader :id, :url, :repl, :board, :title, :author, :answer, :content, :preview, :timestamp, :vote_count, :comment_count, :can_vote, :has_voted, :is_answered, :is_answerable, :is_hidden, :is_pinned, :is_locked, :is_announcement

	def initialize(client, post)
		@client = client
		
		@id = post["id"]
		@url = $BASE_URL + post["url"]
		@title = post["title"]
		@content = post["body"]
		@preview = post["preview"]
		@timestamp = post["timeCreated"]

		@board = Board.new(post["board"])
		@repl = post["repl"] == nil ? nil : Repl.new(@client, post["repl"])
		@author = post["user"] == nil ? "[deleted user]" : User.new(@client, post["user"])
		@answer = post["answer"] == nil ? nil : Comment.new(@client, post["answer"])

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

	def get_comments(order: "new", count: nil, after: nil)
		c = @client.graphql(
			"post",
			Queries.get_posts_comments,
			postId: @id,
			order: order,
			count: count,
			after: after
		)
		c["post"]["comments"]["items"].map { |comment| Comment.new(@client, comment) }
	end

	def get_upvotes(count: nil)
		u = @client.graphql(
			"post",
			Queries.get_posts_upvoters,
			id: @id,
			count: count
		)
		u["post"]["votes"]["items"].map { |vote| User.new(@client, vote["user"]) }
	end

	def create_comment(content)
		c = @client.graphql(
			"createComment",
			Mutations.create_comment,
			input: {
				postId: @id,
				body: content
			}
		)
		Comment.new(@client, c["createComment"]["comment"])
	end

	def edit(title: @title, content: @content, repl_id: @repl.id, show_hosted: false)
		p = @client.graphql(
			"updatePost",
			Mutations.edit_post,
			input: {
				id: @id,
				title: title,
				body: content,
				replId: repl_id,
				showHosted: show_hosted
			}
		)
		Post.new(@client, p["updatePost"]["post"])
	end

	def delete
		@client.graphql(
			"deletePost",
			Mutations.delete_post,
			id: @id
		)
		nil
	end

	def to_s
		@title
	end
end



class User
	attr_reader :id, :username, :name, :pfp, :bio, :cycles, :is_hacker, :timestamp, :subscription, :roles, :organization, :languages

	def initialize(client, user)
		@client = client

		@id = user["id"]
		@username = user["username"]
		@name = user["fullName"]
		@pfp = user["image"]
		@bio = user["bio"]
		@cycles = user["karma"]
		@is_hacker = user["isHacker"]
		@timestamp = user["timeCreated"]
		@subscription = user["subscription"] == nil ? nil : Subscription.new(user["subscription"])
		@roles = user["roles"].map { |role| Role.new(role) }
		@organization = user["organization"] == nil ? nil : Organization.new(user["organization"])
		@languages = user["languages"].map { |lang| Language.new(lang) }
	end

	def get_posts(order: "new", count: nil, after: nil)
		p = @client.graphql(
			"user",
			Queries.get_user_posts,
			username: @username,
			order: order,
			count: count,
			after: after
		)
		p["user"]["posts"]["items"].map { |post| Post.new(@client, post) }
	end

	def get_comments(order: "new", count: nil, after: nil)
		c = @client.graphql(
			"user",
			Queries.get_user_comments,
			username: @username,
			order: order,
			count: count,
			after: after
		)
		c["user"]["comments"]["items"].map { |comment| Comment.new(@client, comment) }
	end

	def get_repls(count: nil, order: nil, direction: nil, before: nil, after: nil, pinnedReplsFirst: nil, showUnnamed: nil)
		r = @client.graphql(
			"user",
			Queries.get_user_repls,
			username: @username,
			order: order,
			count: count,
			direction: direction,
			before: before,
			after: after,
			pinnedReplsFirst: pinnedReplsFirst,
			showUnnamed: showUnnamed
		)
		r["user"]["publicRepls"]["items"].map { |repl| Repl.new(@client, repl) }
	end

	def to_s
		@username
	end
end



class LeaderboardUser < User
	attr_reader :cycles_since

	def initialize(client, user)
		super(client, user)
		@cycles_since = user["karmaSince"]
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
					referer: "#{$BASE_URL}/@CodingCactus/repltalk",
					"X-Requested-With": "ReplTalk"
				)
				.post(
					"#{$BASE_URL}/graphql", 
					form: payload
				)
		begin data = JSON.parse(r)
		rescue
			puts "\e[31mERROR\n#{r}\e[0m"
			return nil
		end
		if data.include?("errors")
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

	def get_comment(id)
		c = graphql(
			"comment",
			Queries.get_comment,
			id: id
		)
		Comment.new(self, c["comment"])
	end

	def get_repl(url)
		r = graphql(
			"ReplView",
			Queries.get_repl,
			url: url
		)
		Repl.new(self, r["repl"])
	end

	def get_board(name)
		b = graphql(
			"boardBySlug",
			Queries.get_board,
			slug: name
		)
		Board.new(b["board"])
	end

	def get_leaderboard(count: nil, since: nil, after: nil)
		u = graphql(
			"LeaderboardQuery",
			Queries.get_leaderboard,
			count: count,
			since: since,
			after: after
		)
		u["leaderboard"]["items"].map { |user| LeaderboardUser.new(self, user) }
	end
	
	def get_posts(board: "all", order: "new", count: nil, after: nil, search: nil, languages: nil)
		p = graphql(
			"PostsFeed",
			Queries.get_posts,
			baordSlugs: [board],
			order: order,
			count: count,
			after: after,
			searchQuery: search,
			languages: languages
		)
		p["posts"]["items"].map { |post| Post.new(self, post) }
	end

	def create_post(board_name, title, content, repl_id: nil, show_hosted: false)
		p = graphql(
			"createPost",
			Mutations.create_post,
			input: {
				boardId: get_board(board_name).id,
				title: title,
				body: content,
				replId: repl_id,
				showHosted: show_hosted
			}
		)
		Post.new(self, p["createPost"]["post"])
	end
end