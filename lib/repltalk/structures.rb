require "http"
require "json"

module ReplTalk
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



	class ReplComment
		attr_reader :id, :content, :author, :repl, :replies

		def initialize(client, comment)
			@client = client

			@id = comment["id"]
			@content = comment["body"]
			@author = comment["user"] == nil ? nil : User.new(@client, comment["user"])
			@repl = comment["repl"] == nil ? nil : Repl.new(@client, comment["repl"])
			@replies = comment["replies"] == nil ? nil : comment["replies"].map { |c| ReplComment.new(@client, c) }
		end

		def create_comment(content)
			c = @client.graphql(
				"ReplViewCreateReplCommentReply",
				GQL::Mutations::REPLY_REPL_COMMENT,
				input: {
					replCommentId: @id,
					body: content
				}
			)
			ReplComment.new(@client, c["createReplCommentReply"])
		end

		def edit(content)
			c = @client.graphql(
				"ReplViewCommentsUpdateReplComment",
				GQL::Mutations::EDIT_REPL_COMMENT,
				input: {
					id: @id,
					body: content
				}
			)
			ReplComment.new(@client, c["updateReplComment"])
		end

		def delete
			@client.graphql(
				"ReplViewCommentsDeleteReplComment",
				GQL::Mutations::DELETE_REPL_COMMENT,
				id: @id
			)
			nil
		end

		def to_s
			@content
		end
	end



	class Repl
		attr_reader :id, :url, :title, :author, :description, :timestamp, :size, :language, :img_url, :origin_url, :is_private, :is_always_on

		def initialize(client, repl)
			@client = client

			@id = repl["id"]
			@url = $BASE_URL + repl["url"]
			@title = repl["title"]
			@author = User.new(@client, repl["user"])
			@description = repl["description"]
			@timestamp = repl["timeCreated"]
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
				GQL::Queries::GET_REPL_FORKS,
				url: @url,
				count: count,
				after: after
			)
			f["repl"]["publicForks"]["items"].map { |repl| Repl.new(@client, repl) }
		end

		def get_comments(count: nil, after: nil)
			c = @client.graphql(
				"ReplViewComments",
				GQL::Queries::GET_REPL_COMMENTS,
				url: @url,
				count: count,
				after: after
			)
			c["repl"]["comments"]["items"].map { |comment| ReplComment.new(@client, comment) }
		end

		def create_comment(content)
			c = @client.graphql(
				"ReplViewCreateReplComment",
				GQL::Mutations::CREATE_REPL_COMMENT,
				input: {
					replId: @id,
					body: content
				}
			)
			ReplComment.new(@client, c["createReplComment"])
		end

		def to_s
			@title
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
				GQL::Queries::GET_POST,
				id: @post_id
			)
			Post.new(@client, p["post"])
		end

		def get_comments
			c = @client.graphql(
				"comment",
				GQL::Queries::GET_COMMENTS_COMMENTS,
				id: @id
			)
			c["comment"]["comments"].map { |comment| Comment.new(@client, comment) }
		end

		def get_parent
			c = @client.graphql(
				"comment",
				GQL::Queries::GET_PARENT_COMMENT,
				id: @id
			)
			c["comment"]["parentComment"] == nil ? nil : Comment.new(@client, c["comment"]["parentComment"])
		end

		def create_comment(content)
			c = @client.graphql(
				"createComment",
				GQL::Mutations::CREATE_COMMENT,
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
				GQL::Mutations::EDIT_COMMENT,
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
				GQL::Mutations::DELETE_COMMENT,
				id: @id
			)
			nil
		end

		def report(reason)
			@client.graphql(
				"createBoardReport",
				GQL::Mutations::REPORT_COMMENT,
				id: @id,
				reason: reason
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
			@author = post["user"] == nil ? nil : User.new(@client, post["user"])
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
				GQL::Queries::GET_POSTS_COMMENTS,
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
				GQL::Queries::GET_POSTS_UPVOTERS,
				id: @id,
				count: count
			)
			u["post"]["votes"]["items"].map { |vote| User.new(@client, vote["user"]) }
		end

		def create_comment(content)
			c = @client.graphql(
				"createComment",
				GQL::Mutations::CREATE_COMMENT,
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
				GQL::Mutations::EDIT_POST,
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
				GQL::Mutations::DELETE_POST,
				id: @id
			)
			nil
		end

		def report(reason)
			@client.graphql(
				"createBoardReport",
				GQL::Mutations::REPORT_POST,
				id: @id,
				reason: reason
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
			return nil if user == nil
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
				GQL::Queries::GET_USER_POSTS,
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
				GQL::Queries::GET_USER_COMMENTS,
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
				GQL::Queries::GET_USER_REPLS,
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
end