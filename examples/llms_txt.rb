#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/mdphlex"

class LlmsTxt < MDPhlex::MD
  def initialize(links)
    @links = links
  end

  def view_template
    h1 "MDPhlex"
    ul do
      @links.each do |name, url|
        li { a(href: url) { name } }
      end
    end
  end
end

if __FILE__ == $0
  links = {
    "Docs" => "https://github.com/martinemde/mdphlex/blob/main/README.md",
    "RubyGem" => "https://rubygems.org/gems/mdphlex",
    "Source" => "https://github.com/martinemde/mdphlex",
  }

  output = LlmsTxt.new(links).call
  puts output

  File.write(
    File.join(File.dirname(__FILE__), "llms.txt"),
    output
  )

  puts "\n---"
  puts "Output saved to examples/llms.txt"
end
