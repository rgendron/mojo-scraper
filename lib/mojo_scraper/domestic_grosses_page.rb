# -*- encoding: utf-8 -*-
module Mojo
  class DomesticGrossesPage
    LETTERS = ['#'] + ('A'..'Z').to_a

    attr_reader :page, :letter, :page_number, :uri, :movie_data, :movies

    def self.get_page_by_uri(uri = nil)
      Mojo::DomesticGrossesPage.new(uri)
    rescue => e
      puts e
    end

    def self.get_page(page_number = 1)
      query = "page=#{page_number}&p=.htm"
      uri = 'http://www.boxofficemojo.com/alltime/domestic.htm?' + query
      Mojo::DomesticGrossesPage.new(uri)
    rescue => e
      puts e
    end

    def initialize(uri)
      add = Addressable::URI.parse(uri)
      @page_number = (add.query_values['page'] || 1).to_i
      @page = http_client.get(uri)
      @movie_data = parse_movie_data
    end

    def parse_movie_data
      path = 'table:nth-of-type(2) table:nth-of-type(2) table[cellpadding="5"]'
      page.at(path).css('tr:nth-of-type(n+2)').map do |tr|
        link = tr.at_css('td:nth-of-type(2) a')
        {
          id: link && /id=(.*)\.htm/i.match(link['href'])[1],
          rank: row_cell_text(tr, 1), title: row_cell_text(tr, 2),
          studio: row_cell_text(tr, 3), domestic_gross: row_cell_text(tr, 4),
          year: row_cell_text(tr, 5)
        }
      end
    end

    def row_cell_text(row, cell_number)
      row.at_css("td:nth-of-type(#{cell_number})").text
    end

    def movies
      @movies ||= @movie_data.map { |m| Mojo::Movie.new(m[:id], m) }
    end

    private

    def http_client
      Mechanize.new
    end
  end
end
