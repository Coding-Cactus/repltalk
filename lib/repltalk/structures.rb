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



	class Tag
		attr_reader :id, :repl_count, :creator_count, :is_trending, :repls_tagged_today_count

		def initialize(client, tag)
			@client = client

			@id = tag["id"]
			@repl_count = tag["replCount"]
			@is_trending = tag["isTrending"]
			@creator_count = tag["creatorCount"]
			@repls_tagged_today_count = tag["replsTaggedTodayCount"]
		end

		def get_repls(count: nil, after: nil)
			r = @client.graphql(
				"ExploreTrendingRepls",
				GQL::Queries::GET_TAGS_REPLS,
				tag: @id,
				count: count,
				after: after
			)
			r["tag"]["repls"]["items"].map { |repl| Repl.new(@client, repl) }
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
		attr_reader :id, :url, :title, :author, :description, :timestamp, :size, :run_count, :fork_count, :language, :img_url, :origin_url, :is_private, :is_always_on, :tags

		def initialize(client, repl)
			@client = client

			@id = repl["id"]
			@url = $BASE_URL + repl["url"]
			@title = repl["title"]
			@author = User.new(@client, repl["user"])
			@description = repl["description"].to_s
			@timestamp = repl["timeCreated"]
			@size = repl["size"]
			@run_count = repl["runCount"]
			@fork_count = repl["publicForkCount"]
			@language = Language.new(repl["lang"])
			@image_url = repl["imageUrl"]
			@origin_url = repl["origin"] == nil ? nil : $BASE_URL + repl["origin"]["url"]

			@is_private = repl["isPrivate"]
			@is_always_on = repl["isAlwaysOn"]

			@tags = repl["tags"].map { |tag| Tag.new(@client, tag) }
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

		def add_reaction(type)
			r = @client.graphql(
				"ReplViewReactionsToggleReactions",
				GQL::Mutations::TOGGLE_REACTION,
				input: {
					replId: @id,
					react: true,
					reactionType: type
				}
			)
			if r["setReplReaction"]["reactions"] == nil
				@reactions
			else
				@reactions = r["setReplReaction"]["reactions"].map { |reaction| Reaction.new(reaction) }
			end
		end

		def remove_reaction(type)
			r = @client.graphql(
				"ReplViewReactionsToggleReactions",
				GQL::Mutations::TOGGLE_REACTION,
				input: {
					replId: @id,
					react: false,
					reactionType: type
				}
			)
			@reactions = r["setReplReaction"]["reactions"].map { |reaction| Reaction.new(reaction) }
		end

		def publish(description, image_url, tags, enable_comments: true)
			r = @client.graphql(
				"PublishRepl",
				GQL::Mutations::PUBLISH_REPL,
				input: {
					replId: @id,
					replTitle: @title,
					description: description,
					imageUrl: image_url,
					tags: tags,
					enableComments: enable_comments,
				}
			)
			Repl.new(@client, r["publishRepl"])
		end

		def unpublish
			r = @client.graphql(
				"ReplViewHeaderActionsUnpublishRepl",
				GQL::Mutations::UNPUBLISH_REPL,
				input: {
					replId: @id
				}
			)
			Repl.new(@client, r["unpublishRepl"])
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
			@timestamp = post["timeCreated"]

			@board = post["board"].nil? ? nil : Board.new(post["board"])
			@repl = post["repl"] == nil ? nil : Repl.new(@client, post["repl"])
			@author = post["user"] == nil ? nil : User.new(@client, post["user"])
			@answer = post["answer"] == nil ? nil : Comment.new(@client, post["answer"])
			
			@content = post["body"]
			@preview = post["preview"]

			if @content == "" && @repl != nil # new post type
				if post["replComment"].nil? # no post attached
					@url = @repl.url
					@title = @repl.title
					@content = @repl.description
				else # post attached
					@url = "#{@repl.url}?c=#{post["replComment"]["id"]}"
					@content = post["replComment"]["body"]
				end
				@preview = @content.length > 150 ? @content[0..150] : @content
			end			

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
		attr_reader :id, :username, :name, :pfp, :bio, :cycles, :is_hacker, :timestamp, :subscription, :roles, :languages

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
			@roles = user["roles"].map { |role| Role.new(role) }
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
end