namespace :fixtures do
  desc 'Refresh spec fixtures with fresh data from boxofficemojo.com'
  task :refresh do
    require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

    MOJO_PAGE_SAMPLES.each_pair do |url, fixture|
      page = `curl -is "#{url}"`
      path = File.dirname(__FILE__) + "/../spec/fixtures/#{fixture}"
      File.open(File.expand_path(path), 'w') { |f| f.write(page) }
    end
  end
end
