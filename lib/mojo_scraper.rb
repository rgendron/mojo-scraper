require 'rubygems'
require 'mechanize'
require 'cgi'
require 'net/http'
require 'addressable/uri'
module Mojo
  ADJUST_YEAR = 2015
end
Dir["#{File.expand_path(File.dirname(__FILE__))}/mojo_scraper/*.rb"].each { |file| require file }
