module Mojo
  class Movie
    attr_accessor(:id, :url, :title, :main_page, :charts, :timestamp,
                  :release_date)

    def self.get_top_domestic_movies(count = 100, offset = 0)
      first_page = offset / 100 + 1
      last_page =  ((offset + count) / 100.0).ceil
      pages = [*first_page..last_page]
      movies = pages.map { |i| Mojo::DomesticGrossesPage.get_page(i).movies }
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

    def adjusted_box_office_lifetime
      @adjusted_box_office_lifetime || main_page.adjusted_box_office_lifetime
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
      { id: id, title: title,
        worldwide_box_office: worldwide_box_office,
        domestic_box_office: domestic_box_office,
        foreign_box_office: foreign_box_office,
        adjusted_box_office_lifetime: adjusted_box_office_lifetime,
        directors: directors, actors: actors, producers: producers,
        charts: charts,
        release_date: release_date,
        timestamp: timestamp }
    end

    def main_page
      @main_page ||= Mojo::MainPage.new(id)
    end
  end
end
