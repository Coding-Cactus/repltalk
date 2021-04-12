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
                GQL::Queries.get_user,
                username: name
            )
            return nil if u == nil || u["user"] == nil
            User.new(self, u["user"])
        end

        def get_user_by_id(id)
            u = graphql(
                "user",
                GQL::Queries.get_user_by_id,
                user_id: id
            )
            return nil if u == nil || u["user"] == nil
            User.new(self, u["user"])
        end

        def search_user(username, count: 10)
            u = graphql(
                "usernameSearch",
                GQL::Queries.user_search,
                username: username,
                count: count
            )
            return nil if u["usernameSearch"] == nil
            u["usernameSearch"].map { |user| User.new(self, user) }
        end

        def get_post(id)
            p = graphql(
                "post",
                GQL::Queries.get_post,
                id: id
            )
            return nil if p == nil || p["post"] == nil
            Post.new(self, p["post"])
        end

        def get_comment(id)
            c = graphql(
                "comment",
                GQL::Queries.get_comment,
                id: id
            )
            return nil if c == nil || c["comment"] == nil
            Comment.new(self, c["comment"])
        end

        def get_repl(url)
            r = graphql(
                "ReplView",
                GQL::Queries.get_repl,
                url: url
            )
            return nil if  r == nil || r["repl"] == nil
            Repl.new(self, r["repl"])
        end

        def get_repl_comment(id)
            c = graphql(
                "ReplViewComment",
                GQL::Queries.get_repl_comment,
                id: id
            )
            return nil if c == nil || c["replComment"] == nil
            ReplComment.new(self, c["replComment"])
        end

        def get_board(name)
            b = graphql(
                "boardBySlug",
                GQL::Queries.get_board,
                slug: name
            )
            return nil if b == nil || b["board"] == nil
            Board.new(b["board"])
        end

        def get_leaderboard(count: nil, since: nil, after: nil)
            u = graphql(
                "LeaderboardQuery",
                GQL::Queries.get_leaderboard,
                count: count,
                since: since,
                after: after
            )
            u["leaderboard"]["items"].map { |user| LeaderboardUser.new(self, user) }
        end
        
        def get_posts(board: "all", order: "new", count: nil, after: nil, search: nil, languages: nil)
            p = graphql(
                "PostsFeed",
                GQL::Queries.get_posts,
                boardSlugs: [board],
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
                GQL::Mutations.create_post,
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