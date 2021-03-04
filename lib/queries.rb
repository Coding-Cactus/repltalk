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
			timeCreated
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
			timeCreated
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
			timeCreated
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

	def Queries.get_user_comments
		"query ProfileComments($username: String!, $after: String, $order: String, $count: Int) {
			user: userByUsername(username: $username) {
				id
				displayName
				comments(after: $after, order: $order, count: $count) {
					items {
						id
						...ProfileCommentsComment
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

		fragment ProfileCommentsComment on Comment {
			id
			body
			timeCreated
			url
			isAnswer
			...CommentVoteControlComment
			user {
				id
				fullName
				username
				image
				bio
				karma
				isHacker
				timeCreated
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
			}
			post {
				id
				title
				url
				user {
					id
					username
					url
					__typename
				}
				board {
					id
					name
					url
					slug
					__typename
				}
				__typename
			}
			__typename
		}

		fragment CommentVoteControlComment on Comment {
			id
			voteCount
			canVote
			hasVoted
			__typename
		}"
	end

	def Queries.get_post
		"query post($id: Int!) {
			post(id: $id) {
				id
				title
				preview(removeMarkdown: true, length: 150)
				body
				isAnnouncement
				url
				isAnswerable
				isHidden
				answeredBy {
					id
					...PostAnsweredCardUser
					__typename
				}
				answer {
					id
					...PostAnsweredCardComment
					__typename
				}
				board {
					id
					url
					description
					slug
					__typename
				}
				...PostDetailPost
				__typename
			}
		}

		fragment PostDetailPost on Post {
			id
			title
			body
			timeCreated
			canReport
			hasReported
			isAnnouncement
			isPinned
			isLocked
			isHidden
			commentCount
			isAnswered
			isAnswerable
			...PostVoteControlPost
			user {
				id
				timeCreated		
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
				...UserPostHeaderUser
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
			__typename
		}

		fragment PostVoteControlPost on Post {
			id
			voteCount
			canVote
			hasVoted
			__typename
		}

		fragment UserPostHeaderUser on User {
			id
			image
			isHacker
			isModerator: hasRole(role: MODERATOR)
			isAdmin: hasRole(role: ADMIN)
			...DepreciatedUserLabelUser
			...UserLinkUser
			__typename
		}

		fragment UserLinkUser on User {
			id
			url
			username
			__typename
		}

		fragment DepreciatedUserLabelUser on User {
			id
			image
			username
			url
			karma
			__typename
		}

		fragment PostAnsweredCardUser on User {
			id
			username
			...DepreciatedUserLabelUser
			__typename
		}

		fragment PostAnsweredCardComment on Comment {
			id
			url
			__typename
		}"
	end

	def Queries.get_comment
		"query comment ($id: Int!) {
			comment(id: $id) {
				id
				url
				isAnswer
				...CommentDetailComment
				comments {
					id
					url
					isAnswer
					...CommentDetailComment
					__typename
				}
				__typename
			}
		}

		fragment DepreciatedUserLabelUser on User {
			id
			fullName
			username
			image
			bio
			karma
			isHacker
			timeCreated
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

		fragment CommentDetailComment on Comment {
			id
			body
			timeCreated
			url
			isAnswer
			...CommentVoteControlComment
			user {
				id
				username
				...DepreciatedUserLabelWithImageUser
				__typename
			}
			post {
				id
				__typename
			}
			__typename
		}

		fragment DepreciatedUserLabelWithImageUser on User {
			id
			image
			...DepreciatedUserLabelUser
			__typename
		}

		fragment CommentVoteControlComment on Comment {
			id
			voteCount
			canVote
			hasVoted
			__typename
		}"
	end
end