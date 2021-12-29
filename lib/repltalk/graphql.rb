module ReplTalk
	module GQL
		module Fields
			ROLES = "
				id
				name
				key
				tagline
			"

			LANGUAGE = "
				id
				key
				displayName
				tagline
				icon
				category
			"

			BOARD = "
				id
				name
				color
				description
			"

			USER = "
				id
				fullName
				username
				image
				bio
				karma
				isHacker
				timeCreated
				roles {
					#{ROLES}
				}
				languages {
					#{LANGUAGE}
				}
			"

			TAG = "
				id
				replCount
				replsTaggedTodayCount
				creatorCount
				isTrending
			"

			REACTIONS = "
				id
				type
				count
			"

			REPL = "
				id
				url
				title
				description
				timeCreated
				size
				runCount
				publicForkCount
				imageUrl
				isPrivate
				isAlwaysOn
				tags {
					#{TAG}
				}
				reactions {
					#{REACTIONS}
				}
				lang {
					#{LANGUAGE}
				}
				user {
					#{USER}
				}
				origin {
					url
				}
			"

			COMMENT = "
				id
				body
				timeCreated
				url
				isAnswer
				voteCount
				canVote
				hasVoted
				user {
					#{USER}
				}
				post {
					id
				}
			"

			REPL_COMMENT = "
				id
				body
				timeCreated
				user {
					#{USER}
				}
				repl {
					#{REPL}
				}
			"

			POST = "
				id
				title
				body
				preview(removeMarkdown: true, length: 150)
				url
				commentCount
				isHidden
				isPinned
				isLocked
				isAnnouncement
				timeCreated
				isAnswered
				isAnswerable		
				voteCount
				canVote
				hasVoted
				user {
					#{USER}
				}
				repl {
					#{REPL}
				}
				board {
					#{BOARD}
				}
				answer {
					#{COMMENT}
				}
			"
		end


		module Queries
			GET_USER = "
				query userByUsername($username: String!) {
					user: userByUsername(username: $username) {
						#{Fields::USER}
					}
				}
			"

			GET_USER_BY_ID = "
				query user($user_id: Int!) {
					user: user(id: $user_id) {
						#{Fields::USER}
					}
				}
			"

			USER_SEARCH = "
				query usernameSearch($username: String!, $count: Int) {
					usernameSearch(query: $username, limit: $count) {
						#{Fields::USER}
					}
				}
			"

			GET_USER_POSTS = "
				query user($username: String!, $after: String, $order: String, $count: Int) {
					user: userByUsername(username: $username) {
						posts(after: $after, order: $order, count: $count) {
							items {
								#{Fields::POST}
							}
						}
					}
				}
			"

			GET_USER_COMMENTS = "
				query user($username: String!, $after: String, $order: String, $count: Int) {
					user: userByUsername(username: $username) {
						comments(after: $after, order: $order, count: $count) {
							items {
								#{Fields::COMMENT}
							}
						}
					}
				}
			"

			GET_USER_REPLS = "
				query user($username: String!, $count: Int, $order: String, $direction: String, $before: String, $after: String, $pinnedReplsFirst: Boolean, $showUnnamed: Boolean) {
					user: userByUsername(username: $username) {
						publicRepls(count: $count, order: $order, direction: $direction, before: $before, after: $after, pinnedReplsFirst: $pinnedReplsFirst, showUnnamed: $showUnnamed) {
							items {
								#{Fields::REPL}
							}
						}
					}
				}
			"

			GET_POST = "
				query post($id: Int!) {
					post(id: $id) {
						#{Fields::POST}
					}
				}
			"

			GET_POSTS_COMMENTS = "
				query post($postId: Int!, $order: String, $count: Int, $after: String) {
					post(id: $postId) {
						comments(order: $order, count: $count, after: $after) {
							items {
								#{Fields::COMMENT}
							}
						}
					}
				}
			"

			GET_POSTS_UPVOTERS = "
				query post($id: Int!, $count: Int) {
					post(id: $id) {
						votes(count: $count) {
							items {
								user {
									#{Fields::POST}
								}
							}
						}
					}
				}
			"

			GET_COMMENT = "
				query comment ($id: Int!) {
					comment(id: $id) {
						#{Fields::COMMENT}
					}
				}
			"

			GET_COMMENTS_COMMENTS = "
				query comment ($id: Int!) {
					comment(id: $id) {
						comments {
							#{Fields::COMMENT}
						}
					}
				}
			"

			GET_PARENT_COMMENT = "
				query comment ($id: Int!) {
					comment(id: $id) {
						parentComment {
							#{Fields::COMMENT}
						}
					}
				}
			"

			GET_REPL = "
				query ReplView($url: String!) {
					repl(url: $url) {
						... on Repl {
							#{Fields::REPL}
						}
					}
				}
			"

			GET_REPL_FORKS = "
				query ReplViewForks($url: String!, $count: Int!, $after: String) {
					repl(url: $url) {
						... on Repl {
							publicForks(count: $count, after: $after) {
								items {
									#{Fields::REPL}
								}
							}
						}
					}
				}
			"

			GET_REPL_COMMENTS = "
				query ReplViewComments($url: String!, $count: Int, $after: String) {
					repl(url: $url) {
						... on Repl {
							comments(count: $count, after: $after) {
								items {
									#{Fields::REPL_COMMENT}
									replies {
										#{Fields::REPL_COMMENT}
									}
								}
							}
						}
					}
				}
			"

			GET_REPL_COMMENT = "
				query ReplViewComment($id: Int!) {
					replComment(id: $id) {
						... on ReplComment {
								#{Fields::REPL_COMMENT}
						}
					}
				}
			"


			GET_BOARD = "
				query boardBySlug($slug: String!) {
					board: boardBySlug(slug: $slug) {
						#{Fields::BOARD}
					}
				}
			"

			GET_POSTS = "
				query ReplPostsFeed($options: ReplPostsQueryOptions) {	
					replPosts(options: $options) {		
						items {
							#{Fields::POST}
						}
					}
				}
			"

			GET_LEADERBOARD = "
				query LeaderboardQuery($count: Int, $after: String, $since: KarmaSince) {
					leaderboard(count: $count, after: $after, since: $since) {
						items {
							#{Fields::USER}
							karmaSince: karma(since: $since)
						}
					}
				}
			"

			GET_EXPLORE_FEATURED_REPLS = "
				query ExploreFeaturedRepls {
					featuredRepls {
						#{Fields::REPL}
					}
				}
			"

			GET_TAG = "
				query ExploreTrendingRepls($tag: String!) {
					tag(id: $tag) {
						#{Fields::TAG}
					}
				}
			"

			GET_TRENDING_TAGS = "
				query ExploreFeed($count: Int) {
					trendingTagsFeed(initialTagsCount: $count) {
						initialTags {
							#{Fields::TAG}
						}
					}
				}
			"

			GET_TAGS_REPLS = "
				query ExploreTrendingRepls($tag: String!, $count: Int, $after: String) {
					tag(id: $tag) {
						repls(limit: $count, after: $after) {
							items {
								#{Fields::REPL}
							}
						}
					}
				}
			"
		end


		module Mutations
			include Fields

			CREATE_POST = "
				mutation createPost($input: CreatePostInput!) {
					createPost(input: $input) {
						post {
							#{Fields::POST}
						}
					}
				}
			"

			EDIT_POST = "
				mutation updatePost($input: UpdatePostInput!) {
					updatePost(input: $input) {
						post {
							#{Fields::POST}
						}
					}
				}
			"

			DELETE_POST = "
				mutation deletePost($id: Int!) {
					deletePost(id: $id) {
						id
					}
				}
			"

			CREATE_COMMENT = "
				mutation createComment($input: CreateCommentInput!) {
					createComment(input: $input) {
						comment {
							#{Fields::COMMENT}
						}
					}
				}
			"

			EDIT_COMMENT = "
				mutation updateComment($input: UpdateCommentInput!) {
					updateComment(input: $input) {
						comment {
							#{Fields::COMMENT}
						}
					}
				}
			"

			DELETE_COMMENT = "
				mutation deleteComment($id: Int!) {
					deleteComment(id: $id) {
						id
					}
				}
			"

			CREATE_REPL_COMMENT = "
				mutation ReplViewCreateReplComment($input: CreateReplCommentInput!) {
					createReplComment(input: $input) {
						... on ReplComment {
							#{Fields::REPL_COMMENT}
						}
					}
				}
			"

			REPLY_REPL_COMMENT = "
				mutation ReplViewCreateReplCommentReply($input: CreateReplCommentReplyInput!) {
					createReplCommentReply(input: $input) {
						... on ReplComment {
							#{Fields::REPL_COMMENT}
						}
					}
				}
			"

			EDIT_REPL_COMMENT = "
				mutation ReplViewCommentsUpdateReplComment($input: UpdateReplCommentInput!) {
					updateReplComment(input: $input) {
						... on ReplComment {
							#{Fields::REPL_COMMENT}
						}
					}
				}
			"

			DELETE_REPL_COMMENT = "
				mutation ReplViewCommentsDeleteReplComment($id: Int!) {
					deleteReplComment(id: $id) {
						... on ReplComment {
							id
						}
					}
				}
			"

			PUBLISH_REPL = "
				mutation PublishRepl($input: PublishReplInput!) {
					publishRepl(input: $input) {
						... on Repl {
							#{Fields::REPL}
						}
					}
				}
			"

			UNPUBLISH_REPL = "
				mutation ReplViewHeaderActionsUnpublishRepl($input: UnpublishReplInput!) {
					unpublishRepl(input: $input) {
						... on Repl {
							#{Fields::REPL}
						}
					}
				}
			"

			TOGGLE_REACTION = "
				mutation ReplViewReactionsToggleReactions($input: SetReplReactionInput!) {
					setReplReaction(input: $input) {
						... on Repl {
							reactions {
								#{Fields::REACTIONS}
							}
						}
					}
				}
			"

			REPORT_POST = "
				mutation createBoardReport($id: Int!, $reason: String!) {
					createBoardReport(postId: $id, reason: $reason) {
						id
					}
				}
			"

			REPORT_COMMENT = "
				mutation createBoardReport($id: Int!, $reason: String!) {
					createBoardReport(commentId: $id, reason: $reason) {
						id
					}
				}
			"
		end
	end
end