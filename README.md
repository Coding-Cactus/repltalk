# repltalk

A ruby client for the [repl talk](https://repl.it/talk) gql api.

### Gemfile
```
gem "repltalk"
```

### Getting Started

```ruby
require "repltak"

client = Client.new
```

Once you have your client initialized, you can start getting users, posts, comments etc.

### Client
+ `#get_user username` Get a user from their username. Returns `User`


### User
+ `#id` User's id
+ `#username` User's username
+ `#name` User's full name
+ `#pfp` URL of the user's pfp
+ `#bio` User's bio
+ `#cycles` How many cycles the user has
+ `#is_hacker` Whether the user has the hacker plan
+ `#roles` User's roles. Returns an array of `Role`s
+ `#languages` Languages that the user has used. Returns array of `Language`s

### Role
+ `#name` Role's name
+ `#key` Role's key
+ `#tagline` Role's tagline

### Language
+ `#id` Language's id (like 'python3' or 'html')
+ `#key` Language's key
+ `#name` Language's name (like 'Python' or 'HTML, CSS, JS')
+ `#tagline` Language's tagline
+ `#icon` URL of the language's icon