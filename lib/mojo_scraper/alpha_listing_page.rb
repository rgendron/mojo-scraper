# -*- encoding: utf-8 -*-
module Mojo
  class AlphaListingPage
    LETTERS = ['#'] + ('A'..'Z').to_a

    attr_reader :page, :letter, :page_number, :uri, :movie_data, :movies

    def self.get_page_by_uri(uri = nil)
      Mojo::AlphaListingPage.new(uri)
    rescue => e
      puts e
    end

    def self.get_page_by_letter(letter, page = 1)
      query = "letter=#{letter}&page=#{page}"
      uri = 'http://www.boxofficemojo.com/movies/alphabetical.htm?' + query
      Mojo::AlphaListingPage.new(uri)
    rescue => e
      puts e
    end

    def initialize(uri)
      add = Addressable::URI.parse(uri)
      @page_number = (add.query_values['page'] || 1).to_i
      @letter = add.query_values['letter']
      @page = http_client.get(uri)
      @movie_data = parse_movie_data
    end

    def parse_movie_data
      page.search('table:nth-of-type(2) tr:nth-of-type(n+2)').map do |tr|
        link = tr.at_css('td:nth-of-type(1) a')
        { title: link.text,
          id: /id=(.*)\.htm/i.match(link['href'])[1],
          studio: tr.at_css('td:nth-of-type(2)').text,
          domestic_gross: tr.at_css('td:nth-of-type(3)').text,
          open:  tr.at_css('td:nth-of-type(7)').text
          }
      end
    end

    def other_page_numbers
      (1..total_pages_for_letter).to_a - [page_number]
    end

    def total_pages_for_letter
      page.at('.alpha-nav-holder').css('a').size + 1
    end

    def movies
      @movies ||= @movie_data.map { |m| Mojo::Movie.new(m[:id], m) }
    end

    private

    def parse_date(date_str)
      Date.strptime(date_str, '%m/%d/%Y')
    end

    def http_client
      Mechanize.new
    end
  end
end
