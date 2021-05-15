require "http"
require "json"

module ReplTalk
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
				GQL::Queries::GET_USER,
				username: name
			)
			return nil if u == nil || u["user"] == nil
			User.new(self, u["user"])
		end

		def get_user_by_id(id)
			u = graphql(
				"user",
				GQL::Queries::GET_USER_BY_ID,
				user_id: id
			)
			return nil if u == nil || u["user"] == nil
			User.new(self, u["user"])
		end

		def search_user(username, count: 10)
			u = graphql(
				"usernameSearch",
				GQL::Queries::USER_SEARCH,
				username: username,
				count: count
			)
			return nil if u["usernameSearch"] == nil
			u["usernameSearch"].map { |user| User.new(self, user) }
		end

		def get_post(id)
			p = graphql(
				"post",
				GQL::Queries::GET_POST,
				id: id
			)
			return nil if p == nil || p["post"] == nil
			Post.new(self, p["post"])
		end

		def get_comment(id)
			c = graphql(
				"comment",
				GQL::Queries::GET_COMMENT,
				id: id
			)
			return nil if c == nil || c["comment"] == nil
			Comment.new(self, c["comment"])
		end

		def get_repl(url)
			r = graphql(
				"ReplView",
				GQL::Queries::GET_REPL,
				url: url
			)
			return nil if  r == nil || r["repl"] == nil
			Repl.new(self, r["repl"])
		end

		def get_repl_comment(id)
			c = graphql(
				"ReplViewComment",
				GQL::Queries::GET_REPL_COMMENT,
				id: id
			)
			return nil if c == nil || c["replComment"] == nil
			ReplComment.new(self, c["replComment"])
		end

		def get_board(name)
			b = graphql(
				"boardBySlug",
				GQL::Queries::GET_BOARD,
				slug: name
			)
			return nil if b == nil || b["board"] == nil
			Board.new(b["board"])
		end

		def get_leaderboard(count: nil, since: nil, after: nil)
			u = graphql(
				"LeaderboardQuery",
				GQL::Queries::GET_LEADERBOARD,
				count: count,
				since: since,
				after: after
			)
			u["leaderboard"]["items"].map { |user| LeaderboardUser.new(self, user) }
		end
		
		def get_posts(board: "all", order: "new", count: nil, after: nil, search: nil, languages: nil)
			p = graphql(
				"PostsFeed",
				GQL::Queries::GET_POSTS,
				boardSlugs: [board],
				order: order,
				count: count,
				after: after,
				searchQuery: search,
				languages: languages
			)
			p["posts"]["items"].map { |post| Post.new(self, post) }
		end

		def get_explore_featured_repls
			r = graphql(
				"ExploreFeaturedRepls",
				GQL::Queries::GET_EXPLORE_FEATURED_REPLS
			)
			r["featuredRepls"].map { |repl| Repl.new(self, repl) }
		end

		def get_trending_tags(count: nil)
			t = graphql(
				"ExploreFeed",
				GQL::Queries::GET_TRENDING_TAGS,
				count: count
			)
			t["trendingTagsFeed"]["initialTags"].map { |tag| Tag.new(self, tag) }
		end

		def get_tag(tag)
			t = graphql(
				"ExploreTrendingRepls",
				GQL::Queries::GET_TAG,
				tag: tag
			)
			Tag.new(self, t["tag"])
		end

		def create_post(board_name, title, content, repl_id: nil, show_hosted: false)
			p = graphql(
				"createPost",
				GQL::Mutations::CREATE_POST,
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
end