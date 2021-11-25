#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    # Most members have separate divs,
    # but some have "Name: Positition" in the name field

    def name
      return raw_name.split(':').first.tidy if raw_position.empty?

      raw_name
    end

    def position
      derived_position.split(/ and (?=Minister)/).flat_map do |posn|
        posn.split(/ (?=Commander)/)
      end
    end

    private

    def raw_name
      noko.css('.sppb-person-designation').text.sub('Honourable', '').tidy
    end

    def raw_position
      noko.css('.sppb-person-introtext').text.tidy
    end

    def derived_position
      return raw_name.split(':').last.tidy if raw_position.empty?

      raw_position
    end
  end

  class Members
    def member_container
      noko.css('.sppb-person-information-wrap')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
