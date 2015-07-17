Gem::Specification.new do |spec|
  spec.name          = "lita-meetup-rsvps"
  spec.version       = "0.1.0"
  spec.authors       = ["Simon Lundström"]
  spec.email         = ["simmel@soy.se"]
  spec.description   = "Get updated on RSVPs in the channel for your Meetup events"
  spec.summary       = "Get RSVP updates on Meetup events"
  spec.homepage      = "https://github.com/simmel/lita-meetup-rsvps"
  spec.license       = "ISC license"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
