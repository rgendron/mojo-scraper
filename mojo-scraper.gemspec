# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mojo_scraper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Ryan Gendron']
  gem.description   = 'Scrapes Box Office Mojo pages.'
  gem.summary       = 'Easily access the publicly available information on'\
                      'Box Office Mojo.'
  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'mojo-scraper'
  gem.require_paths = ['lib']
  gem.version       = Mojo::Scraper::VERSION
  gem.platform      = Gem::Platform::RUBY

  gem.license = 'MIT'

  gem.add_dependency 'addressable'
  gem.add_dependency 'mechanize', '~> 2'

  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'fakeweb'
  gem.add_development_dependency 'rake', '~> 10'
end
