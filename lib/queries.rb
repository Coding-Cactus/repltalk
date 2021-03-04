class Queries
	def Queries.get_user
		"query userByUsername($username: String!) {
			user: userByUsername(username: $username) {
				id
				username
				fullName
				image
				url
				...ProfileHeaderUser
				__typename
			}
		}

		fragment ProfileHeaderUser on User {
			id
			fullName
			username
			image
			bio
			karma
			isHacker
			roles {
				id
				name
				key
				tagline
				__typename
			}
			organization {
				id
				name
				__typename
			}
			languages {
				id
				key
				displayName
				tagline
				icon
				__typename
			}
			__typename
		}"
	end

	def Queries.get_user_by_id
		"query user($user_id: Int!) {
			user: user(id: $user_id) {
				id
				username
				fullName
				image
				url
				...ProfileHeaderUser
				__typename
			}
		}

		fragment ProfileHeaderUser on User {
			id
			fullName
			username
			image
			bio
			karma
			isHacker
			roles {
				id
				name
				key
				tagline
				__typename
			}
			organization {
				id
				name
				__typename
			}
			languages {
				id
				key
				displayName
				tagline
				icon
				__typename
			}
			__typename
		}"
	end

	def Queries.get_user_posts
		"query ProfilePosts($username: String!, $after: String, $order: String, $count: Int) {
			user: userByUsername(username: $username) {
				id
				displayName
				posts(after: $after, order: $order, count: $count) {
					items {
						id
						isHidden
						...PostsFeedItemPost
						board {
							id
							name
							url
							color
							__typename
						}
						__typename
					}
					pageInfo {
						nextCursor
						__typename
					}
					__typename
				}
				__typename
			}
		}

		fragment PostsFeedItemPost on Post {
			id
			title
			body
			preview(removeMarkdown: true, length: 150)
			url
			commentCount
			isPinned
			isLocked
			isAnnouncement
			timeCreated
			isAnswered
			isAnswerable
			...PostVoteControlPost
			...PostLinkPost
			user {
				id
				username
				isHacker
				image
				...UserLabelUser
				...UserLinkUser
				__typename
			}
			repl {
				id
				url
				title
				description
				isPrivate
				isAlwaysOn
				lang {
					id
					icon
					key
					displayName
					tagline
					__typename
				}
				__typename
			}
			board {
				id
				name
				color
				__typename
			}
			recentComments(count: 3) {
				id
				...SimpleCommentComment
				__typename
			}
			__typename
		}

		fragment PostVoteControlPost on Post {
			id
			voteCount
			canVote
			hasVoted
			__typename
		}

		fragment PostLinkPost on Post {
			id
			url
			__typename
		}

		fragment UserLabelUser on User {
			id
			username
			karma
			...UserLinkUser
			__typename
		}

		fragment UserLinkUser on User {
			id
			url
			username
			roles {
				id
				name
				key
				tagline
				__typename
			}
			organization {
				id
				name
				__typename
			}
			languages {
				id
				key
				displayName
				tagline
				icon
				__typename
			}
			__typename
		}

		fragment SimpleCommentComment on Comment {
			id
			user {
				id
				...UserLabelUser
				...UserLinkUser
				__typename
			}
			preview(removeMarkdown: true, length: 500)
			timeCreated
			__typename
		}"
	end
end