#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "mdphlex"

class HTMLInMarkdownExample < MDPhlex::MD
  def view_template
    h1 { "HTML in Markdown" }

    p { "Markdown allows inline HTML like <strong>this bold text</strong> and <em>this italic text</em>." }

    p do
      plain "You can use HTML entities directly: &copy; &amp; &lt;div&gt;"
    end

    h2 { "Complex HTML" }

    p do
      plain <<~HTML
        You can even include complex HTML structures:
        <div class="alert" style="border: 1px solid red;">
          <h3>Warning!</h3>
          <p>This is an alert box created with HTML.</p>
        </div>
      HTML
    end

    h2 { "Mixing Markdown and HTML" }

    p do
      plain "You can mix "
      strong { "Markdown formatting" }
      plain " with <code>HTML tags</code> seamlessly."
    end
  end
end

if __FILE__ == $0
  output = HTMLInMarkdownExample.new.call
  puts output

  File.write(
    File.join(File.dirname(__FILE__), "html_in_markdown_output.md"),
    output
  )

  puts "\n---"
  puts "Output saved to examples/html_in_markdown_output.md"
end
