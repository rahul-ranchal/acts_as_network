# -*- encoding: utf-8 -*-
# stub: acts_as_network 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "acts_as_network".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Zetetic LLC (Stephen Lombardo), David Kennedy".freeze]
  s.date = "2017-02-24"
  s.description = "Simplify the definition and storage of \"network\" relationships, especially useful for social networks.".freeze
  s.email = ["david.kennedy@examtime.com".freeze]
  s.files = [".gitignore".freeze, ".rvmrc".freeze, "Gemfile".freeze, "Gemfile.lock".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "acts_as_network.gemspec".freeze, "lib/acts_as_network.rb".freeze, "lib/acts_as_network/version.rb".freeze, "test/database.yml".freeze, "test/fixtures/channels.yml".freeze, "test/fixtures/invites.yml".freeze, "test/fixtures/people.yml".freeze, "test/fixtures/people_people.yml".freeze, "test/fixtures/shows.yml".freeze, "test/network_test.rb".freeze, "test/schema.rb".freeze, "test/test_helper.rb".freeze]
  s.homepage = "https://github.com/ExamTime/acts_as_network".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Simplify social network relationships".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3-ruby>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<rails>.freeze, [">= 3.2.0"])
    else
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3-ruby>.freeze, [">= 0"])
      s.add_dependency(%q<rails>.freeze, [">= 3.2.0"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3-ruby>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 3.2.0"])
  end
end
