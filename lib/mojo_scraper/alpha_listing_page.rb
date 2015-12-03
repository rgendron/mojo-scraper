# -*- encoding: utf-8 -*-
module Mojo
  class AlphaListingPage
    LETTERS = ['#'] + ('A'..'Z').to_a
    USER_AGENTS = ['Windows IE 6', 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox', 'Linux Konqueror']

    attr_reader :page, :letter, :page_number, :uri, :movie_data, :movies

    def self.get_page_by_uri(uri = nil)
      Mojo::AlphaListingPage.new(uri)
    rescue => e
      puts e
    end

    def self.get_page_by_letter(letter, page = 1)
      uri = "http://www.boxofficemojo.com/movies/alphabetical.htm?letter=#{letter}&page=#{page}&p=.htm"
      Mojo::AlphaListingPage.new(uri)
    rescue => e
      puts e
    end

    def initialize(uri)
      add = Addressable::URI.parse(uri)
      @page_number = add.query_values['page'] ? add.query_values['page'].to_i : 1
      @letter = add.query_values['letter']
      @page = http_client.get(uri)
      parse_movie_data
    end

    def parse_movie_data
      @movie_data = []
      table = page.at('body table:nth-of-type(2)')
      table.css('tr:nth-of-type(n+2)').each do |tr|
        link = tr.at_css('td:nth-of-type(1) a')
        studio = tr.at_css('td:nth-of-type(2)').text
        domestic_gross = tr.at_css('td:nth-of-type(3)').text
        open = tr.at_css('td:nth-of-type(7)').text
        @movie_data << {
          title: link.text,
          id: /id=(.*)\.htm/i.match(link['href'])[1],
          studio: studio,
          domestic_gross: domestic_gross,
          open: open
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
      @movies ||= @movie_data.map { |m| Mojo::Movie.new(m[:id], title: m[:title]) }
    end

    private

    def parse_date(date_str)
      Date.strptime(date_str, '%m/%d/%Y')
    end

    def http_client
      Mechanize.new do |agent|
        agent.user_agent_alias = USER_AGENTS.sample
        agent.max_history = 0
      end
    end
  end
end
