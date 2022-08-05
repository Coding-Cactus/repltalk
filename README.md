<p align="center"><img alt="repltak" src="https://repltalk-logo.codingcactus.repl.co/logo.png" /></p>


A ruby wrapper for the [repl talk](https://repl.it/talk) gql api.

# Getting Started

## Gemfile
```
gem "repltalk"
```

## Initializing Client

```ruby
require "repltalk"

client = ReplTalk::Client.new
```

Once you have your client initialized, you can start getting users, posts, comments etc.

***

# Code Snippets
A few small snippets of examples of what you can do with the repltalk gem

### Get CodingCactus' posts from the top 100 posts:
```ruby
client.get_posts(order: "Top", count: 100).select { |post| post.author.username == "CodingCactus" }
```

### Get the 10 most recent ruby post's URLs
```ruby
client.get_posts(count: 10, languages: ['ruby']).map { |post| post.url }
```

### See how many people have forked CodingCactus' classrooms repl
```ruby
client.get_repl("/@CodingCactus/classrooms").fork_count
```

### See how many comments in a post mention CodingCactus
```ruby
mentions = 0
client.get_post(33995).get_comments(count: 999999999).each do |comment|
	mentions += 1 if comment.content.include?("@CodingCactus")
	comment.get_comments.each { |child_comment| mentions += 1 if child_comment.content.include?("@CodingCactus") }
	sleep 0.25 # need to be careful with rate limits
end
```

### See how many repls of each language CodingCactus has
```ruby
lang_count = client.get_user("CodingCactus").get_repls(count: 999999).reduce(Hash.new(0)) do |langs, repl|
  langs[repl.language.id] += 1
  langs
end
```

***
# All Methods Documentation

## Client
+ `#get_user username` Get a user from their username. Returns `User`
+ `#get_user_by_id id` Get a user from their id. Returns `User`
+ `#search_user query, :count` Search for users whose username start with the query. Returns array of `User`s. **Need to be logged in, unfortunately**
+ `#get_post id` Get a post from it's id. Returns `Post`
+ `#get_comment id` Get a comment from it's id. Returns `Comment`
+ `#get_repl url` Get a repl from it's url. Returns `Repl`
+ `#get_repl_comment id` Get a repl comment from its id. Returns `ReplComment`
+ `#get_board name` Get a board from it's name. Returns `Board`
+ `#get_posts :board, :order, :count, :after, :search` Get posts from repltalk. Returns array of `Post`s
+ `#create_post board_name, title, content, :repl_id, :show_hosted` Create a repl talk post. Returns `Post`
+ `#get_explore_featured_repls` Get the featured repls on explore. Returns array of `Repl`s
+ `#get_trending_tags :count` Get the tags which are trending on explore. Returns array of `Tag`s
+ `#get_tag id` Get a tag. Returns `Tag`

## User
+ `#id` User's id
+ `#username` User's username
+ `#name` User's full name
+ `#pfp` URL of the user's pfp
+ `#bio` User's bio
+ `#timestamp` When the account was made
+ `#is_hacker` Whether the user has the hacker plan
+ `#roles` User's roles. Returns an array of `Role`s
+ `#languages` Languages that the user has used. Returns array of `Language`s
+ `#get_posts :order, :count, :after` Get the user's posts. Returns array of `Post`s
+ `#get_comments :order, :count, :after` Get the user's comments. Returns array of `Comment`s
+ `get_repls :count, :order, :direction, :before, :after, :pinnedReplsFirst, :showUnnamed` Get the user's repls. Returns array of `Repl`s

## Post
+ `#id` Post's id
+ `#url` Post's url
+ `#repl` Repl attached to the post. Returns nil if there is none. Else returns `Repl`
+ `#board` Board that the post is from. Returns `Board`
+ `#title` Post's title
+ `#author` Post's author. Returns `User`
+ `#content` Post's content
+ `#preview` Preview of the post's content.
+ `#timestamp` When the post was posted
+ `#vote_count` How many votes there post has
+ `#comment_count` How many comments the post has
+ `#answer` The comment that has been marked as the answer. Returns `nil` if there is none, else `Comment`
+ `#is_answered` Whether an answer has been selected
+ `#is_answerable` Whether you are able to answer the post
+ `#is_announcement` Whether the post in marked as an announcement
+ `#is_pinned` Whether the post is pinned
+ `#is_locked` Whether the post is locked
+ `#is_hidden` Whether the post is hidden (unlisted)
+ `#get_upvotes :count` Get the users that have upvoted the post. Count defaults to 10. Returns array or `User`s
+ `#get_comments :order, :count, :after` Get the post's comments. Returns array of `Comment`s
+ `#create_comment  content` Comment on the post. Returns `Comment`
+ `#edit :title, :content, :repl_id, :show_hosted` Edit the post. Returns `Post`
+ `#delete` Delete the post
+ `#report reason` Report the post

## Comment
+ `#id` Comment's id
+ `#url` Comment's url
+ `#author` Comment's author. Returns `User`
+ `#content` Comment's content
+ `#post_id` Id of the post that the comment is on
+ `#is_answer` Whether the comment has been selected as the answer to a post
+ `#vote_count` How many votes the comment has
+ `#timestamp` When the comment was made
+ `#get_post` Get the post that the comment was made on. Returns `Post`
+ `#get_comments` Get the children comments of the comment. Returns array of `Comment`s
+ `#get_parent` Get the parent comment of a child comment. Returns `nil` if it isn't a child, else `Comment`
+ `#create_comment content` reply to the comment. Returns `Comment`
+ `#edit content` Edit the comment. Returns `Comment`
+ `#delete` Delete the comment
+ `#report reason` Report the comment

## Repl
+ `#id` Repl's id
+ `#url` Repl's URL
+ `#title` Repl's name
+ `#author` Repl's author. Returns `User`
+ `#description` Repl's description
+ `#timestamp` When the repl was made
+ `#size` How many bytes the repl is
+ `#run_count` How many times the repl has been run
+ `#fork_count` How many times the repl has been forked
+ `#language` Repl's language. Returns `Language`
+ `#image_url` Repl image's url
+ `#origin_url` Url of the repl from which this repl was forked
+ `#is_private` Whether the repl is private
+ `#is_always_on` Whether the repl is always on
+ `#tags` Tags tagged on the repl. Returns array of `Tag`s
+ `#reactions` Reactions reacted on the repl. Returns array of `Reaction`s
+ `#get_forks` Repl's forks. Returns array of `Repl`s
+ `#get_comments` Repl's comments. Returns array of `ReplComment`s
+ `#create_comment content` Comment on the repl
+ `#add_reaction type` Add a reaction to the repl
+ `#remove_reaction type` Remove a reaction from the repl
+ `#publish description, image_url, tags, :enable_comments` Publish the repl. Use this to publish an update too
+ `#unpublish` Unpublish the repl


## ReplComment
+ `#id` Comment's id
+ `#content` Comment's content
+ `#author` Comment's author. Returns `User`
+ `#repl` Repl the comment was made on. Returns `Repl`
+ `#replies` Comment's replies. Returns array of `ReplComment`s
+ `#create_comment content` Reply to the repl comment
+ `#edit content` Edit the repl comment
+ `#delete` Delete the repl comment

## Tag
+ `#id` Tag's id (name)
+ `#repl_count` How many repls are listed under the tag
+ `#creator_count` How many different users are listed under the tag
+ `#is_trending` Whether the tag is trending
+ `#repls_tagged_today_count` How many repls have been published with the tag today
+ `#get_repls :count, :after` Get the top 10 repls that have the tag. Returns array of `Repl`s

## Reaction
+ `#id` Reaction's id
+ `#type` Reaction's type (heart, eyes etc.)
+ `#count` How many people have reacted with this reaction on the repl


## Language
+ `#id` Language's id (like 'python3' or 'html')
+ `#key` Language's key
+ `#name` Language's name (like 'Python' or 'HTML, CSS, JS')
+ `#tagline` Language's tagline
+ `#category` Category that the language is in
+ `#icon` URL of the language's icon

## Role
+ `#name` Role's name
+ `#key` Role's key
+ `#tagline` Role's tagline

## Board
+ `#id` Board's id
+ `#name` Board's name
+ `#color` Board's color
+ `#description` Board's description
