<p align="center"><img alt="repltak" src="https://repltalk-logo.codingcactus.repl.co/logo.png" /></p>


A ruby client for the [repl talk](https://repl.it/talk) gql api.

### Gemfile
```
gem "repltalk"
```

### Getting Started

```ruby
require "repltalk"

client = Client.new
```

Once you have your client initialized, you can start getting users, posts, comments etc.

***

### Client
+ `#get_user username` Get a user from their username. Returns `User`
+ `#get_user_by_id id` Get a user from their id. Returns `User`
+ `#get_post id` Get a post from it's id. Returns `Post`
+ `#get_comment id` Get a comment from it's id. Returns `Comment`


### User
+ `#id` User's id
+ `#username` User's username
+ `#name` User's full name
+ `#pfp` URL of the user's pfp
+ `#bio` User's bio
+ `#cycles` How many cycles the user has
+ `#timestamp` When the account was made
+ `#is_hacker` Whether the user has the hacker plan
+ `#roles` User's roles. Returns an array of `Role`s
+ `#languages` Languages that the user has used. Returns array of `Language`s
+ `#get_posts :order, :count, :after` Get the user's posts. All arguments are optional (e.g. you can do `#get_post count: 50`). Order defaults to 'new'. Count defaults to 30. After defaults to 0. Returns array of `Post`s
+ `#get_comments :order, :count, :after` Get the user's comments. All arguments are optional (e.g. you can do `#get_comment count: 50`). Order defaults to 'new'. Count defaults to 30. After defaults to 0. Returns array of `Comment`s

### Post
+ `#id` Post's id
+ `#url` Post's url
+ `#repl` Repl attatched to the post. Returns nil if there is none. Else returns `Repl`
+ `#board` Board that the post is from. Returns `Board`
+ `#title` Post's title
+ `#author` Post's author. Returns `User`
+ `#content` Post's content
+ `#preview` Preview of the post's content.
+ `#timestamp` When the post was posted
+ `#vote_count` How many votes there post has
+ `#comment_count` How many comments the post has
+ `#is_answered` Whether an answer has been selected
+ `#is_answerable` Whether you are able to answer the post
+ `#is_announcement` Whether the post in marked as an announcement
+ `#is_pinned` Whether the post is pinned
+ `#is_locked` Whether the post is locked
+ `#is_hidden` Whether the post is hidden (unlisted)

### Comment
+ `#id` Comment's id
+ `#url` Comment's url
+ `#author` Comment's author. Returns `User`
+ `#content` Comment's content
+ `#post_id` Id of the post that the comment is on
+ `#is_answer` Whether the comment has been selected as the answer to a post
+ `#vote_count` How many votes teh comment has
+ `#timestamp` When the comment was made
+ `#comments` Get the children comments of the comment. Returns array of `Comments`
+ `#get_post` Get the post that the comment was made on. Returns `Post`

### Role
+ `#name` Role's name
+ `#key` Role's key
+ `#tagline` Role's tagline

### Organization
+ `#id` Organization's id
+ `#name` Organization's name

### Language
+ `#id` Language's id (like 'python3' or 'html')
+ `#key` Language's key
+ `#name` Language's name (like 'Python' or 'HTML, CSS, JS')
+ `#tagline` Language's tagline
+ `#icon` URL of the language's icon

### Repl
+ `#id` Repl's id
+ `#url` Repl's URL
+ `#title` Repl's name
+ `#description` Repl's description
+ `#language` Repl's language. Returns `Language`
+ `#is_private` Whetehr the repl is private
+ `#is_always_on` Whether the repl is always on

### Board
+ `#id` Board's id
+ `#name` Board's name
+ `#color` Board's color
