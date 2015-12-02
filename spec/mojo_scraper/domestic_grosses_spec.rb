# encoding: UTF-8

require 'spec_helper'
require 'mojo_scraper'

describe Mojo::DomesticGrossesPage do
	url = "http://www.boxofficemojo.com/alltime/domestic.htm?page=1&p=.htm"
	let(:page) { Mojo::DomesticGrossesPage.new(url) }

	describe ".get_domestic_grosses_page_by_url" do
		it "creates a new instance of Mojo::DomesticGrossesPage" do
			expect(page).to be_instance_of Mojo::DomesticGrossesPage
		end
	end


	describe ".movie_data" do 
		let(:starwars4) {{
			:rank=>"7", 
			:title=>"Star Wars", 
			:id=>"starwars4", 
			:studio=>"Fox", 
			:domestic_gross=>"$460,998,007", 
			:year=>"1977^"}}

			it "retrieves an array of hashes of movie_data" do
				expect(page.movie_data.size).to eq 100
				expect(page.movie_data[6]).to eq starwars4
			end
		end

		describe "domestic grosses movies" do
			file = File.absolute_path(File.dirname(__FILE__) + '/../fixtures/starwars4.html')
			FakeWeb.register_uri(:get, %r|http://www\.boxofficemojo\.com/movies/\?id=|,
				:body => File.read(file),
				:content_type => "text/html")
			it "should retreive at list of movies" do 
				page.movies.each { |movie| expect(movie).to be_instance_of Mojo::Movie}
			end
		end

	end