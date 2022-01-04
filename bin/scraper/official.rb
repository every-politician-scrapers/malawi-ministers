#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

# Rather than parsing lots of awkward layout, standardise it here
class FixLayout < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('.sppb-person-designation').each do |node|
        node.content = node.content.gsub(', Minister', ': Minister')
      end
    end.to_s
  end
end


class MemberList
  class Member
    # Most members have separate divs,
    # but some have "Name: Positition" in the name field

    def name
      derived_name.delete_suffix('.')
    end

    def position
      derived_position.gsub(/\.$/, '').split(/ and (?=Minister)/).flat_map do |posn|
        posn.split(/ (?=Commander)/)
      end
    end

    private

    def raw_name
      noko.css('.sppb-person-designation').text.delete_prefix('Honourable').delete_prefix('Honorable').sub(/, ?MP/, '').tidy
    end

    def derived_name
      return raw_name.split(':').first.tidy if raw_position.empty?

      raw_name
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
    decorator FixLayout

    def member_container
      noko.css('.sppb-person-information-wrap')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
