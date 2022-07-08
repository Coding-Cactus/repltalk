Gem::Specification.new do |s|
	s.name        = 'repltalk'
	s.version     = '4.5.0'
	s.license     = 'MIT'
	s.summary     = "A Ruby client for the ReplTalk API"
	s.description = "With the ReplTalk gem, you can easily interect with the repltalk GraphQL API. See https://github.com/Coding-Cactus/repltalk for documentation."
	s.author      = 'CodingCactus'
	s.email       = 'codingcactus.cc@gmail.com'
	s.files       = ["lib/repltalk.rb", "lib/repltalk/client.rb", "lib/repltalk/graphql.rb", "lib/repltalk/structures.rb"]
	s.homepage    = 'https://github.com/Coding-Cactus/repltalk'
	s.metadata    = { "source_code_uri" => "https://github.com/Coding-Cactus/repltalk" }
	s.add_runtime_dependency 'http', '~> 4.4', '>= 4.4.1'
	s.add_runtime_dependency 'json', '~> 2.5', '>= 2.5.1'
end