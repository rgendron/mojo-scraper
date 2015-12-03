require 'spec_helper'
require 'mojo_scraper'

describe 'Mojo::Movie' do
  describe 'valid movie' do
    subject { Mojo::Movie.new('starwars4') }
    let(:main_page) { Mojo::MainPage.new('starwars4') }

    it 'finds the title' do
      expect(subject.title).to eq main_page.title
    end

    it 'finds the directors' do
      expect(subject.directors).to eq main_page.directors
    end

    it 'finds the actors' do
      expect(subject.actors).to eq main_page.actors
    end

    it 'finds the producers' do
      expect(subject.producers).to eq main_page.producers
    end

    it 'finds the release_date' do
      expect(subject.release_date).to eq main_page.release_date
    end

    it 'finds the worldwide box office' do
      expect(subject.worldwide_box_office).to eq main_page.worldwide_box_office
    end

    it 'finds the domestic box office' do
      expect(subject.domestic_box_office).to eq main_page.domestic_box_office
    end

    it 'finds the foreign box office' do
      expect(subject.foreign_box_office).to eq main_page.foreign_box_office
    end

    it 'finds the adjusted box office' do
      expect(subject.adjusted_domestic_box_office_lifetime).to eq main_page.adjusted_domestic_box_office_lifetime
    end

    it 'find the timestamp' do
      expect(subject.timestamp).to be_instance_of Time
    end
  end

  describe 'movie lists' do
    let(:top_250) { Mojo::Movie.get_top_domestic_movies(250) }
    let(:top_75_offset) { Mojo::Movie.get_top_domestic_movies(75, 175) }

    it 'finds the top 250 movies' do
      expect(top_250.count).to eq 250
      expect(top_250.first).to be_instance_of Mojo::Movie
      expect(top_250.last).to be_instance_of Mojo::Movie
      expect(top_250.last.id).to eq 'pursuitofhappyness'
    end

    it 'finds the top 75 movies offset by 175' do
      expect(top_75_offset.count).to eq 75
      expect(top_75_offset.first).to be_instance_of Mojo::Movie
      expect(top_75_offset.last).to be_instance_of Mojo::Movie
      expect(top_75_offset.last.id).to eq 'pursuitofhappyness'
    end
  end
end
