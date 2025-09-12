#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/mdphlex"

# This outputs the same as the following ugly ERB code:

erb = <<~ERB
  ## Basic Information
  Document: <%= @content[:document_name].presence || 'N/A' %><% if @content[:source_url].present? %> [View Source](<%= @content[:source_url] %>)<% end %>
  * Description: <%= @content[:description].presence || 'N/A' %>
  <% if @content[:status].present? %>* Status: <%= @content[:status] %>
  <% end %><% if @content[:category].present? %>* Category: <%= @content[:category] %>
  <% end %><% if @content[:priority].present? %>* Priority: <%= @content[:priority] %>
  <% end %><% if @content[:author].present? %>* Author: <%= @content[:author] %>
  <% end %><% if @content[:tags].present? && @content[:tags].any? %>* Tags: <%= @content[:tags].join(', ') %>
  <% end %><% if @content[:topics].present? && @content[:topics].any? %>* Topics: <%= @content[:topics].join(', ') %>
  <% end %>
ERB

begin
  require "erb"
  require "active_support/core_ext/object/blank"
rescue LoadError
  puts "ERB is not installed. Ignoring comparison with ERB."
  erb = nil
end

class DocumentInfo < MDPhlex::MD
  def initialize(content)
    @content = content
  end

  def view_template
    h2 "Basic Information"

    p do
      plain "Document: #{@content[:document_name] || 'N/A'}"
      if @content[:source_url]
        plain " "
        a(href: @content[:source_url]) { "View Source" }
      end
    end

    ul do
      li "Description: #{@content[:description] || 'N/A'}"

      li "Status: #{@content[:status]}" if @content[:status]
      li "Category: #{@content[:category]}" if @content[:category]
      li "Priority: #{@content[:priority]}" if @content[:priority]
      li "Author: #{@content[:author]}" if @content[:author]
      li "Tags: #{@content[:tags].join(', ')}" if @content[:tags]&.any?
      li "Topics: #{@content[:topics].join(', ')}" if @content[:topics]&.any?
    end
  end
end

if __FILE__ == $0
  @content = {
    document_name: "Document 1",
    source_url: "https://example.com",
    description: "Description 1",
    status: "Active",
    category: "Category 1",
    priority: "Priority 1",
    author: "Author 1",
    tags: ["Tag 1", "Tag 2"],
    topics: ["Topic 1", "Topic 2"],
  }

  erb_output = ERB.new(erb).result(binding)
  puts "ERB output:"
  puts "==========="
  puts erb_output
  puts "---"

  output = DocumentInfo.new(@content).call
  puts "MDPhlex output:"
  puts "==============="
  puts output

  File.write(
    File.join(File.dirname(__FILE__), "ugly_erb_output.md"),
    output
  )

  puts "\n---"
  puts "Output saved to examples/ugly_erb_output.md"
end
