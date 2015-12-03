# -*- encoding: utf-8 -*-
module Mojo
  class DomesticGrossesPage
    LETTERS = ['#'] + ('A'..'Z').to_a
    USER_AGENTS = ['Windows IE 6', 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox', 'Linux Konqueror']
    PER_PAGE = 100
    attr_reader :page, :letter, :page_number, :uri, :movie_data, :movies

    def self.get_page_by_uri(uri = nil)
      Mojo::DomesticGrossesPage.new(uri)
    rescue => e
      puts e
    end

    def self.get_page(page_number = 1)
      uri = "http://www.boxofficemojo.com/alltime/domestic.htm?page=#{page_number}&p=.htm"
      Mojo::DomesticGrossesPage.new(uri)
      # rescue => e
      # puts e
    end

    def initialize(uri)
      add = Addressable::URI.parse(uri)
      @page_number = add.query_values['page'] ? add.query_values['page'].to_i : 1
      @page = http_client.get(uri)
      parse_movie_data
      # @movie_ids = parse_movie_ids
      # links = page.at('body table:nth-of-type(2)').css('tr td:nth-of-type(1) a')
      # @movie_ids = links.map {|x| /id=(.*)\.htm/i.match(x['href'])[1] }
      # @movie_titles = links.map(&:text)
    end

    def parse_movie_data
      @movie_data = []
      table = page.at('body table:nth-of-type(2) table:nth-of-type(2) table[cellpadding="5"]')
      table.css('tr:nth-of-type(n+2)').each do |tr|
        rank = tr.at_css('td:nth-of-type(1)').text
        # puts rank
        title = tr.at_css('td:nth-of-type(2)').text

        if link = tr.at_css('td:nth-of-type(2) a')
          id = /id=(.*)\.htm/i.match(link['href'])[1]
        end

        studio = tr.at_css('td:nth-of-type(3)').text
        domestic_gross = tr.at_css('td:nth-of-type(4)').text
        year = tr.at_css('td:nth-of-type(5)').text
        @movie_data << {
          rank: rank,
          title: title,
          id: id,
          studio: studio,
          domestic_gross: domestic_gross,
          year: year
        }

        # worldwide_gross = tr.at_css('td:nth-of-type(4)').text
        # domestic_gross = tr.at_css('td:nth-of-type(5)').text
        # overseas_gross = tr.at_css('td:nth-of-type(7)').text
        # year = tr.at_css('td:nth-of-type(9)').text
      end
    end

    def movies
      @movies ||= @movie_data.map { |m| Mojo::Movie.new(m[:id], title: m[:title]) }
    end

    private

    def http_client
      Mechanize.new do |agent|
        agent.user_agent_alias = USER_AGENTS.sample
        agent.max_history = 0
      end
    end
  end
end
