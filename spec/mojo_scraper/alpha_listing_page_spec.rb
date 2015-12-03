# encoding: UTF-8

require 'spec_helper'
require 'mojo_scraper'

describe Mojo::AlphaListingPage do
  url = 'http://www.boxofficemojo.com/movies/alphabetical.htm?letter=G&page=2'
  let(:middle_page) { Mojo::AlphaListingPage.new(url) }

  describe '.get_alpha_listing_page_by_uri' do
    it 'creates a new instance of Mojo::AlphaListingPage' do
      expect(middle_page).to be_instance_of Mojo::AlphaListingPage
    end
  end

  describe '.get_alpha_listing_page_by_letter' do
    it 'creates a new intance of Mojo::AlphaListingPage ' do
      a_page = Mojo::AlphaListingPage.get_page_by_letter 'G', 2
      expect(a_page).to be_instance_of Mojo::AlphaListingPage
    end
  end

  describe '.movie_data' do
    gettysburg = {
      title: 'Gettysburg',
      id: 'gettysburg',
      studio: 'NL',
      domestic_gross: '$10,769,960',
      open: '10/8/1993'
    }

    it 'retrieves an array of hashes of movie_data' do
      expect(middle_page.movie_data.size).to eq 58
      expect(middle_page.movie_data.last).to eq gettysburg
    end
  end

  describe 'alpha listing movies' do
    path = File.dirname(__FILE__) + '/../fixtures/starwars4.html'
    file = File.absolute_path(path)
    FakeWeb.register_uri(:get, %r{http://www\.boxofficemojo\.com/movies/\?id=},
                         response: File.read(file))
    it 'should retreive at list of movies' do
      middle_page.movies.each { |m| expect(m).to be_instance_of Mojo::Movie }
    end
  end

  it 'calculates total number of pages for letter' do
    expect(middle_page.total_pages_for_letter).to eq 7
  end
end
