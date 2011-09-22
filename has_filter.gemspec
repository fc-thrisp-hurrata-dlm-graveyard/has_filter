# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "has_scope/version"

Gem::Specification.new do |s|
  s.name = "has_filter"
  s.version = HasFilter::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.summary = "Maps controller filters to your DataMapper model scopes"
  s.email = "blueblank@gmail.com"
  s.homepage = "https://github.com/blueblank/has_filter"
  s.description = "Maps controller filters to your DataMapper model scopes"
  s.authors = ['blueblank']

  s.rubyforge_project = "has_filter"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
end
