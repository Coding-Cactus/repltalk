class Queries
	def Queries.get_user
		"query userByUsername($username: String!) {\n  currentUser {\n    id\n    hasAchievementsGate: gate(feature: \"flag-achievements-v0\")\n    __typename\n  }\n  user: userByUsername(username: $username) {\n    id\n    username\n    fullName\n    image\n    url\n    redirectToTeamDashboard\n    ...ProfileHeaderUser\n    __typename\n  }\n}\n\nfragment ProfileHeaderUser on User {\n  id\n  fullName\n  username\n  image\n  isLoggedIn\n  bio\n  karma\n  isHacker\n  roles {\n    id\n    name\n    key\n    tagline\n    __typename\n  }\n  organization {\n    id\n    name\n    __typename\n  }\n  languages {\n    id\n    key\n    displayName\n    tagline\n    icon\n    __typename\n  }\n  __typename\n}"
	end
end