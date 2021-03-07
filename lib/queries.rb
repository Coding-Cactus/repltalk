class Queries
	@@roles = "
		id
		name
		key
		tagline
	"

	@@organization = "	
		id
		name
		country
		postalCode
		state
		city
		timeCreated
	"

	@@subscription = "
		id
		planId
		quantity
		timeCreated
	"

	@@language = "
		id
		key
		displayName
		tagline
		icon
		category
	"

	@@board = "
		id
		name
		color
		description
	"

	@@user = "
		id
		fullName
		username
		image
		bio
		karma
		isHacker
		timeCreated
		roles {
			#{@@roles}
		}
		organization {
			#{@@organization}
		}
		subscription { 
			#{@@subscription}
		}
		languages {
			#{@@language}
		}
	"

	@@repl = "
		id
		url
		title
		description
		size
		imageUrl
		isPrivate
		isAlwaysOn
		lang {
			#{@@language}
		}
		user {
			#{@@user}
		}
		origin {
			url
		}
	"

	@@comment = "
		id
		body
		timeCreated
		url
		isAnswer
		voteCount
		canVote
		hasVoted
		user {
			#{@@user}
		}
		post {
			id
		}
	"

	@@repl_comment = "
		id
		body
		timeCreated
		user {
			#{@@user}
		}
		repl {
			#{@@repl}
		}
	"

	@@post = "
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
			#{@@user}
		}
		repl {
			#{@@repl}
		}
		board {
			#{@@board}
		}
		answer {
			#{@@comment}
		}
	"


	def Queries.get_user
		"query userByUsername($username: String!) {
			user: userByUsername(username: $username) {
				#{@@user}
			}
		}"
	end

	def Queries.get_user_by_id
		"query user($user_id: Int!) {
			user: user(id: $user_id) {
				#{@@user}
			}
		}"
	end

	def Queries.get_user_posts
		"query user($username: String!, $after: String, $order: String, $count: Int) {
			user: userByUsername(username: $username) {
				posts(after: $after, order: $order, count: $count) {
					items {
						#{@@post}
					}
				}
			}
		}"
	end

	def Queries.get_user_comments
		"query user($username: String!, $after: String, $order: String, $count: Int) {
			user: userByUsername(username: $username) {
				comments(after: $after, order: $order, count: $count) {
					items {
						#{@@comment}
					}
				}
			}
		}"
	end

	def Queries.get_user_repls
		"query user($username: String!, $count: Int, $order: String, $direction: String, $before: String, $after: String, $pinnedReplsFirst: Boolean, $showUnnamed: Boolean) {
			user: userByUsername(username: $username) {
				publicRepls(count: $count, order: $order, direction: $direction, before: $before, after: $after, pinnedReplsFirst: $pinnedReplsFirst, showUnnamed: $showUnnamed) {
					items {
						#{@@repl}
					}
				}
			}
		}"
	end

	def Queries.get_post
		"query post($id: Int!) {
			post(id: $id) {
				#{@@post}
			}
		}"
	end

	def Queries.get_posts_comments
		"query post($postId: Int!, $order: String, $count: Int, $after: String) {
			post(id: $postId) {
				comments(order: $order, count: $count, after: $after) {
					items {
						#{@@comment}
					}
				}
			}
		}"
	end

	def Queries.get_posts_upvoters
		"query post($id: Int!, $count: Int) {
			post(id: $id) {
				votes(count: $count) {
					items {
						user {
							#{@@user}
						}
					}
				}
			}
		}"
	end

	def Queries.get_comment
		"query comment ($id: Int!) {
			comment(id: $id) {
				#{@@comment}
			}
		}"
	end

	def Queries.get_comments_comments		
		"query comment ($id: Int!) {
			comment(id: $id) {
				comments {
					#{@@comment}
				}
			}
		}"
	end

	def Queries.get_parent_comment
		"query comment ($id: Int!) {
			comment(id: $id) {
				parentComment {
					#{@@comment}
				}
			}
		}"
	end

	def Queries.get_repl
		"query ReplView($url: String!) {
			repl(url: $url) {
				... on Repl {
					#{@@repl}
				}
			}
		}"
	end

	def Queries.get_repl_forks
		"query ReplViewForks($url: String!, $count: Int!, $after: String) {
			repl(url: $url) {
				... on Repl {
					publicForks(count: $count, after: $after) {
						items {
							#{@@repl}
						}
					}
				}
			}
		}"
	end

	def Queries.get_repl_comments
		"query ReplViewComments($url: String!, $count: Int, $after: String) {
			repl(url: $url) {
				... on Repl {
					comments(count: $count, after: $after) {
						items {
							#{@@repl_comment}
							replies {
								#{@@repl_comment}
							}
						}
					}
				}
			}
		}"
	end

	def Queries.get_board
		"query boardBySlug($slug: String!) {
			board: boardBySlug(slug: $slug) {
				#{@@board}
			}
		}"
	end

	def Queries.get_posts
		"query PostsFeed($order: String, $after: String, $searchQuery: String, $languages: [String!], $count: Int, $boardSlugs: [String!], $pinAnnouncements: Boolean, $pinPinned: Boolean) {
			posts(order: $order, after: $after, searchQuery: $searchQuery, languages: $languages, count: $count, boardSlugs: $boardSlugs, pinAnnouncements: $pinAnnouncements, pinPinned: $pinPinned) {
				items {
					#{@@post}
				}
			}
		}"
	end

	def Queries.get_leaderboard
		"query LeaderboardQuery($count: Int, $after: String, $since: KarmaSince) {
			leaderboard(count: $count, after: $after, since: $since) {
				items {
					#{@@user}
					karmaSince: karma(since: $since)
				}
			}
		}"
	end
end


class Mutations < Queries
	def Mutations.create_post
		"mutation createPost($input: CreatePostInput!) {
			createPost(input: $input) {
				post {
					#{@@post}
				}
			}
		}"
	end

	def Mutations.create_comment
		"mutation createComment($input: CreateCommentInput!) {
			createComment(input: $input) {
				comment {
					#{@@comment}
				}
			}
		}"
	end
end