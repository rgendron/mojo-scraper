# -*- encoding: utf-8 -*-
module Mojo
  class MainPage
    attr_reader(:id, :page, :title, :release_date, :domestic_box_office,
                :foreign_box_office, :charts, :directors, :producers, :actors,
                :writers, :adjusted_box_office_total, :timestamp,
                :adjusted_box_office_lifetime)

    def self.get_page(id)
      Mojo::MainPage.new(id)
    rescue => e
      puts e
    end

    def initialize(id = 'starwars4')
      @id = id
      @page = http_client.get page_url
      @timestamp = parse_timestamp
      @title = container_table.at('tr td:nth-of-type(2) b').text
      @release_date = top_table.at('td:contains("Release Date:") b').text
      set_box_office
      set_players
      set_charts
    end

    def page_url
      query = "id=#{id}.htm&adjust_yr=#{Mojo::ADJUST_YEAR}"
      'http://www.boxofficemojo.com/movies/?' + query
    end

    def worldwide_box_office
      domestic_box_office.to_i + foreign_box_office.to_i
    end

    def parse_domestic_box_office
      dbo_text = box_office_div.at('tr:first-of-type td:nth-of-type(2) b').text
      dbo_text.gsub(/\D/, '').to_i
    end

    def set_players
      if !players_div
        @directors = @writers = @actors = @producers = []
      else
        @directors = parse_players 'Dire'
        @writers = parse_players 'Wri'
        @actors = parse_players 'Act'
        @producers = parse_players 'Pro'
      end
    end

    def parse_players(uri_substring)
      link = players_div.at_css("table>tr>td a[href*=#{uri_substring}]")
      link ? link.parent.parent.next_sibling.css('a').map(&:text) : []
    end

    def set_box_office
      @domestic_box_office = parse_domestic_box_office
      @foreign_box_office =  parse_foreign_box_office
      set_adjusted_box_office
    end

    def set_adjusted_box_office
      elements = top_table.css('tr:first-of-type td b')
      @adjusted_box_office_total = elements.first.text.gsub(/\D/, '').to_i
      if elements[1]
        @adjusted_box_office_lifetime = elements[1].text.gsub(/\D/, '').to_i
      else
        @adjusted_box_office_lifetime = @adjusted_box_office_total
      end
    end

    def parse_foreign_box_office
      td = box_office_div.at('tr:nth-of-type(2) td:nth-of-type(2)')
      td ? td.text.gsub(/\D/, '').to_i : nil
    end

    def set_charts
      @charts = {}
      charts_table.css('tr').each do |row|
        chart = row.css('td')[0].text
        value = row.css('td')[1].text.gsub(/\D/, '').to_i
        @charts[chart] = value if value > 0
      end
    end

    def container_table
      @page.at('#body table table:nth-of-type(1) table')
    end

    def top_table
      container_table.at('tr td:nth-of-type(2) table table')
    end

    def summary_tab
      @page.at('td[width="434px"]')
    end

    def charts_table
      @page.at('.mp_box_tab:contains("Charts")').next_element.at('table')
    end

    def box_office_div
      summary_tab.at('.mp_box:nth-of-type(1) .mp_box_content')
    end

    def players_div
      divs = summary_tab.at('table:first-of-type').css('.mp_box_content')
      divs[2] ? divs[2] : divs[1]
    end

    private

    def parse_date(date_str)
      Date.parse(date_str)
    end

    def parse_timestamp
      Time.parse @page.header['date']
    end

    def http_client
      Mechanize.new
    end
  end
end
