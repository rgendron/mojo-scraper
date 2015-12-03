module Mojo
  class Movie
    attr_accessor :id, :url, :title, :main_page, :charts, :timestamp, :release_date

    def self.get_top_domestic_movies(count = 100, offset = 0)
      # offset=201;count =100; page_start=(offset/100) + 1; page_end = ((offset+count) / 100.0).ceil ; puts "pages: #{page_start}..#{page_end}";movies[offset..offset+count]
      first_page = offset / 100 + 1
      last_page =  ((offset + count) / 100.0).ceil
      # pages_count = (count / 100.0).ceil
      movies = [*first_page..last_page].map { |i| Mojo::DomesticGrossesPage.get_page(i).movies }
      movies.reduce(:concat).drop(offset % 100).take(count)
    end

    def initialize(id, options = {})
      @id = id
      options.each { |k, v| instance_variable_set("@#{k}", v) }
    end

    def url
      @url ||= "http://www.boxofficemojo.com/movies/?id=#{id}.htm"
    end

    def title
      @title ||= main_page.title
    end

    def directors
      @directors ||= main_page.directors
    end

    def producers
      @producers ||= main_page.producers
    end

    def actors
      @actors ||= main_page.actors
    end

    def worldwide_box_office
      @worldwide_box_office ||= main_page.worldwide_box_office
    end

    def domestic_box_office
      @domestic_box_office ||= main_page.domestic_box_office
    end

    def foreign_box_office
      @foreign_box_office ||= main_page.foreign_box_office
    end

    def adjusted_domestic_box_office_lifetime
      @adjusted_domestic_box_office_lifetime || main_page.adjusted_domestic_box_office_lifetime
    end

    def charts
      @charts ||= main_page.charts
    end

    def release_date
      @release_date ||= main_page.release_date
    end

    def timestamp
      @timestamp ||= main_page.timestamp
    end

    def to_json(_options = {})
      to_hash.to_json
    end

    def to_hash
      { title: title,
        id: id,
        worldwide_box_office: worldwide_box_office,
        domestic_box_office: domestic_box_office,
        foreign_box_office: foreign_box_office,
        adjusted_domestic_box_office_lifetime: adjusted_domestic_box_office_lifetime,
        directors: directors,
        actors: actors,
        producers: producers,
        charts: charts,
        release_date: release_date,
        timestamp: timestamp
      }
    end

    def main_page
      @main_page ||= Mojo::MainPage.new(id)
    end
  end
end
