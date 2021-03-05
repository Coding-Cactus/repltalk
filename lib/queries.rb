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
	"

	@@language = "
		id
		key
		displayName
		tagline
		icon
	"

	@@board = "
		id
		name
		color
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
		languages {
			#{@@language}
		}
	"

	@@repl = "
		id
		url
		title
		description
		isPrivate
		isAlwaysOn
		lang {
			#{@@language}
		}
		user {
			#{@@user}
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
		"query ProfilePosts($username: String!, $after: String, $order: String, $count: Int) {
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
		"query ProfileComments($username: String!, $after: String, $order: String, $count: Int) {
			user: userByUsername(username: $username) {
				comments(after: $after, order: $order, count: $count) {
					items {
						#{@@comment}
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

	def Queries.get_comment
		"query comment ($id: Int!) {
			comment(id: $id) {
				#{@@comment}
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
end