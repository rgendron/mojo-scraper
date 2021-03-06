# encoding: UTF-8

require 'spec_helper'
require 'mojo_scraper'

describe Mojo::MainPage do
  let(:main_page) { Mojo::MainPage.new('starwars4') }

  describe '.get_main_page' do
    it 'creates an new instance of Mojo::MainPage' do
      expect(main_page).to be_instance_of Mojo::MainPage
    end
  end

  describe '#title' do
    it "returns movie's title" do
      expect(main_page.title).to eq 'Star Wars'
    end
  end

  describe '#release_date' do
    it "returns movie's release date" do
      expect(main_page.release_date).to eq 'May 25, 1977'
    end
  end

  describe 'valid movie' do
    it "returns movie's domestic box office gross" do
      expect(main_page.domestic_box_office).to eq 460_998_007
    end

    it "returns movie's foreign box office gross" do
      expect(main_page.foreign_box_office).to eq 314_400_000
    end

    it "returns movie's worldwide box office gross" do
      expect(main_page.worldwide_box_office).to eq 314_400_000 + 460_998_007
    end

    it "returns movie's adjust domestic box office gross" do
      expect(main_page.adjusted_box_office_lifetime).to eq 1_485_517_400
    end

    it 'should find the directors' do
      expect(main_page.directors).to eq ['George Lucas']
    end

    it 'should find the writers' do
      expect(main_page.writers).to eq ['George Lucas']
    end

    it 'should find the actors' do
      expected = ['Mark Hamill', 'Harrison Ford', 'Carrie Fisher']
      expect(main_page.actors).to eq expected
    end

    it 'should find the producers' do
      expect(main_page.producers).to eq ['George Lucas']
    end

    it 'should set the timestamp' do
      expect(main_page.timestamp).to be_instance_of Time
    end
  end
end
