Gem::Specification.new do |s|
	s.name        = 'repltalk'
	s.version     = '2.0.1'
	s.license     = 'MIT'
	s.summary     = "A ruby client for the repltalk api"
	s.description = "With the repltalk gem, you can easily interect with the repltalk graphql api. See https://github.com/Coding-Cactus/repltalk for documentation"
	s.author      = 'CodingCactus'
	s.email       = 'codingcactus.cc@gmail.com'
	s.files       = ["lib/repltalk.rb", "lib/queries.rb"]
	s.homepage    = 'https://github.com/Coding-Cactus/repltalk'
	s.metadata    = { "source_code_uri" => "https://github.com/Coding-Cactus/repltalk" }
	s.add_runtime_dependency 'http', '~> 4.4', '>= 4.4.1'
	s.add_runtime_dependency 'json', '~> 2.5', '>= 2.5.1'
end