require 'mojo_scraper'
require 'csv'

namespace :export do
  desc 'Retrieve top domestic films from boxofficemojo.com'
  task :top, [:count, :offset] do |_t, args|
    args.with_defaults(count: 100, offset: 0)
    count = args[:count].to_i
    offset = args[:offset].to_i
    movies = Mojo::Movie.get_top_domestic_movies(count, offset)
    movies.map(&:actors)
    filename = "top_#{offset + 1}-#{offset + count}_domestic_movies.json"
    File.open(filename, 'w') do |f|
      f.write movies.to_json
    end
  end
end
