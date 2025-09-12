# MDPhlex

MDPhlex is a Phlex component for rendering Markdown.
No... not rendering markdown into HTML, rendering plain Markdown, programmatically.

MDPhlex is for dynamically creating context for LLMs, generating llms.txt files from real content, or composing markdown with components.

## Installation

Add this line to your application's Gemfile:

~~~ruby
gem 'mdphlex'
~~~

## Rendering /llms.txt with Rails 8.1

Let's say you want to render:

~~~markdown
# MDPhlex

- [Docs](https://github.com/martinemde/mdphlex/blob/main/README.md)
- [RubyGem](https://rubygems.org/gems/mdphlex)
- [Source](https://github.com/martinemde/mdphlex)
~~~

Generating clean Markdown with a `md.erb` file is ugly (check the [ERb comparison example](examples/mdphlex_over_erb.rb))

**MDPhlex** with [Phlex](https://www.phlex.fun) makes it easy:

```
bundle add phlex-rails mdphlex
bundle exec rails generate phlex:install
```

~~~ruby
# app/views/llms/index.rb
class Views::Llms::Index < MDPhlex::MD
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

# app/controllers/llms_controller.rb
class LlmsController < ApplicationController
  def index
    links = {
      "Docs" => "https://github.com/martinemde/mdphlex/blob/main/README.md",
      "RubyGem" => "https://rubygems.org/gems/mdphlex",
      "Source" => "https://github.com/martinemde/mdphlex"
    }

    respond_to do |format|
      format.md { render markdown: Views::Llms::Index.new(links) }
    end
  end
end

# config/routes.rb
get "/llms.txt", to: "llms#index", format: :md
~~~

## Creating LLM Prompts with MDPhlex

MDPhlex also shines when creating structured prompts for LLMs allowing organization without cluttering the prompt. Here's a simple example using custom tags and showing how it's easy to comment on your prompt without affecting the output.

~~~ruby
class LLMPrompt < MDPhlex::MD
  # Register custom elements for structured prompts
  register_block_element :system
  register_block_element :tools
  register_block_element :tool

  def initialize(task:, tools: [])
    @task = task
    @tools = tools
  end

  def view_template
    system do
      p "You are an AI assistant specialized in #{@task}."

      h2 "Goal"
      # we should define the goal more clearly.
      p "Use the available tools to help the user."

      # what about guardrails?
    end

    if @tools.any?
      tools do
        @tools.each do |tool_def|
          tool name: tool_def[:name] do
            plain tool_def[:description]
            # need to add input schemas
          end
        end
      end
    end
  end
end

# Dynamic prompt generation
prompt = LLMPrompt.new(
  task: "Ruby code analysis",
  tools: [
    { name: "analyze_code", description: "Analyze Ruby code for improvements" },
    { name: "explain_concept", description: "Explain Ruby concepts and patterns" }
  ]
)

puts prompt.call
~~~

This outputs clean, structured markdown perfect for LLMs:

~~~xml
<system>
You are an AI assistant specialized in Ruby code analysis.

## Goal
Use the available tools to help the user.

</system>
<tools>
<tool name="analyze_code">
Analyze Ruby code for improvements</tool>
<tool name="explain_concept">
Explain Ruby concepts and patterns</tool>
</tools>
~~~

MDPhlex also works great for generating regular Markdown content:

~~~ruby
class ArticleContent < MDPhlex::MD
  def initialize(title:, sections:)
    @title = title
    @sections = sections
  end

  def view_template
    h1 @title

    @sections.each do |section|
      h2 section[:heading]

      p section[:content]

      if section[:code_example]
        pre(language: "ruby") { plain section[:code_example] }
      end
    end

    p do
      plain "Learn more in the "
      a(href: "https://docs.example.com") { "documentation" }
      plain "."
    end
  end
end

article = ArticleContent.new(
  title: "Getting Started with Ruby",
  sections: [
    {
      heading: "Variables",
      content: "Ruby variables are dynamically typed and don't require declaration.",
      code_example: "name = 'Alice'\nage = 30"
    }
  ]
)

puts article.call
~~~

Outputs:

~~~markdown
# Getting Started with Ruby

## Variables

Ruby variables are dynamically typed and don't require declaration.

```ruby
name = 'Alice'
age = 30
```

Learn more in the [documentation](https://docs.example.com).
~~~

## Rendering MDPhlex inside Phlex::HTML (and vice versa)

MDPhlex components are Phlex compatible. Integrate them into any Phlex::HTML views or show HTML or other wcomented in Markdown:

~~~ruby
class ArticlePage < Phlex::HTML
  def initialize(article)
    @article = article
  end

  def view_template
    html do
      head do
        title { @article.title }
      end
      body do
        article do
          # Render MDPhlex component inside HTML
          div(class: "markdown-content") do
            plain render(ArticleContent.new(@article))
          end
        end
      end
    end
  end
end

class ArticleContent < MDPhlex::MD
  def initialize(article)
    @article = article
  end

  def view_template
    h1 @article.title

    p @article.summary

    h2 "Contents"

    @article.sections.each do |section|
      h3 section.title
      p section.content
    end
  end
end
~~~

## Why MDPhlex?

*Generating text is easy! Why bother with complex components!?*

This is what it looks like when you generate well formed markdown with ERb:

```
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
```

Compare that to MDPhlex.

```ruby
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
```

Check out the [examples/](examples/) for more.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
