# -*- encoding: utf-8 -*-
module Mojo
  class MainPage

    USER_AGENTS = ["Windows IE 6", "Windows IE 7", "Windows Mozilla", "Mac Safari", "Mac FireFox", "Mac Mozilla", "Linux Mozilla", "Linux Firefox", "Linux Konqueror"]

    attr_reader :id, :page, :title, :release_date, :domestic_box_office, :foreign_box_office,
    :charts, :directors, :producers, :actors, :writers, :adjusted_domestic_box_office_total,
    :adjusted_domestic_box_office_lifetime, :timestamp

    def self.get_page(id_or_uri)
      Mojo::MainPage.new(id_or_uri)
    rescue => e
      puts e
    end

    def initialize(id_or_uri = "starwars4")
      if id_or_uri  =~ URI::regexp
        @id = id_or_uri.split("=").last
        uri = id_or_uri
      else
        @id = id_or_uri
        uri = "http://www.boxofficemojo.com/movies/?id=#{id}.htm&adjust_yr=#{Mojo::ADJUST_YEAR}"
      end
      @page = http_client.get(uri)
      @timestamp = Time.parse @page.header["date"]
      # @timestamp = Time.now
      # puts @page.header.to_s
      @title = container_table.at('tr td:nth-of-type(2) b').text
      @release_date = top_table.at('td:contains("Release Date:") b').text
      dbo_text = box_office_div.at('tr:first-of-type td:nth-of-type(2) b').text
      @domestic_box_office = dbo_text.gsub(/\D/,'').to_i
      parse_adjusted_box_office
      parse_players
      parse_foreign_box_office
      parse_charts
    end

    def worldwide_box_office
      domestic_box_office.to_i + foreign_box_office.to_i
    end

    def parse_players
      if !players_div
        @directors = @writers = @actors = @producers = []
      else
        dlink = players_div.at_css('table>tr>td a[href*=Dire]')
        @directors = dlink ? dlink.parent.parent.next_sibling.css('a').map {|l| l.text } : []

        wlink = players_div.at_css('table>tr>td a[href*=Wri]')
        @writers = wlink ? wlink.parent.parent.next_sibling.css('a').map {|l| l.text } : []

        alink = players_div.at_css('table>tr>td a[href*=Act]')
        @actors = alink ? alink.parent.parent.next_sibling.css('a').map {|l| l.text } : []

        plink = players_div.at_css('table>tr>td a[href*=Pro]')
        @producers = plink ? plink.parent.parent.next_sibling.css('a').map {|l| l.text } : []

        # @directors = players_div.at_css('table>tr>td:nth-of-type(2)').css('a').map {|l| l.text }

        # writers_td = players_div.at_css('table>tr:nth-of-type(2)>td:nth-of-type(2)')
        # @writers = writers_td ? writers_td.css('a').map {|l| l.text } : []

        # actors_td = players_div.at_css('table>tr:nth-of-type(3)>td:nth-of-type(2)')
        # @actors = actors_td ? actors_td.css('a').map {|l| l.text } : []

        # producers_td = players_div.at_css('table>tr:nth-of-type(4)>td:nth-of-type(2)')
        # @producers = producers_td ? producers_td.css('a').map {|l| l.text } : []
      end
    end

    def parse_adjusted_box_office
     elements = top_table.css('tr:first-of-type td b')
     @adjusted_domestic_box_office_total = elements.first.text.gsub(/\D/,'').to_i
     @adjusted_domestic_box_office_lifetime = elements[1] ? elements[1].text.gsub(/\D/,'').to_i : @adjusted_domestic_box_office_total
   end

   def parse_foreign_box_office
    td = box_office_div.at('tr:nth-of-type(2) td:nth-of-type(2)')
    @foreign_box_office = td ? td.text.gsub(/\D/,'').to_i : nil
  end

  def parse_charts
    @charts = {}
    charts_table.css('tr').each do |row|
      chart = row.css('td')[0].text
      value = row.css('td')[1].text.gsub(/\D/,'').to_i
      @charts[chart] = value if value > 0
    end
  end

  def container_table
    @page.at('#body table table:nth-of-type(1) table')
  end

  def top_table 
    container_table.at('tr td:nth-of-type(2) table table');
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

def to_json
  require "json"
  ATTRIBUTES.reduce({}){ |hash,attr| hash[attr.to_sym] = self.send(attr.to_sym);hash }.to_json
end

private

def parse_date(date_str)
  Date.parse(date_str)
end

def http_client
  Mechanize.new do |agent|
    agent.user_agent_alias = USER_AGENTS.sample
    agent.max_history = 0
  end
end

end
end
