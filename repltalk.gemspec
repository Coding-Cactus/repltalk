Gem::Specification.new do |s|
	s.name        = 'repltalk'
	s.version     = '1.0.0'
	s.licenses    = ['MIT']
	s.summary     = "A ruby client for the repltalk api"
	s.description = "With the repltalk gem, you can easily interect with the repltalk graphql api. See https://github.com/Coding-Cactus/repltalk for documentation"
	s.authors     = ["CodingCactus"]
	s.email       = 'codingcactus.cc@gmail.com'
	s.files       = ["lib/repltalk.rb", "lib/queries.rb"]
	s.metadata    = { "source_code_uri" => "https://github.com/Coding-Cactus/repltalk" }
	s.add_runtime_dependency 'http'
	s.add_runtime_dependency 'json'
end