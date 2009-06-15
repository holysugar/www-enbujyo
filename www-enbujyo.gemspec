# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{www-enbujyo}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["holysugar"]
  s.date = %q{2009-06-15}
  s.email = %q{holysugar@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/enbujyo.rb",
     "lib/www/enbujyo.rb",
     "lib/www/enbujyo/player.rb",
     "lib/www/enbujyo/util.rb",
     "test/test_helper.rb",
     "test/www-enbujyo_test.rb",
     "www-enbujyo.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/holysugar/www-enbujyo}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "test/test_helper.rb",
     "test/www-enbujyo_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
