# MDPhlex

MDPhlex is a Phlex component for rendering Markdown. No... not rendering markdown into HTML, rendering plain Markdown, programmatically.

MDPhlex is perfect for dynamically creating context for LLMs, generating an llms.txt file from real content, or composing markdown out of componentized pieces.

## Installation

Add this line to your application's Gemfile:

~~~ruby
gem 'mdphlex'
~~~

## Creating LLM Prompts with MDPhlex

MDPhlex shines when creating structured prompts for LLMs allowing comments and organization without cluttering the prompt. Here's a simple example using custom tags:

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

## Traditional Markdown Generation

MDPhlex also works great for generating regular Markdown content.

### Rails Integration with Markdown Rendering

With Rails 8.1's native markdown support, MDPhlex components integrate seamlessly:

~~~ruby
# app/components/page_component.rb
class PageComponent < MDPhlex::MD
  def initialize(page)
    @page = page
  end

  def view_template
    h1 @page.title

    p do
      em "Last updated: #{@page.updated_at.strftime('%B %d, %Y')}"
    end

    hr

    # Render page sections with proper markdown structure
    @page.sections.each do |section|
      h2 section.heading

      p section.content

      if section.code_example?
        pre(language: section.language) { plain section.code }
      end
    end

    if @page.references.any?
      h2 "References"
      ul do
        @page.references.each do |ref|
          li do
            a(href: ref.url) { ref.title }
          end
        end
      end
    end
  end
end

# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html
      format.md { render markdown: PageComponent.new(@page) }
    end
  end
end
~~~

When someone visits `/pages/123.md`, Rails will render:

~~~markdown
# Getting Started with Ruby

*Last updated: September 12, 2025*

---

## Introduction

Ruby is a dynamic, object-oriented programming language...

## Basic Syntax

Here's how to define a method in Ruby:

```ruby
def greet(name)
  puts "Hello, #{name}!"
end
```

## References
- [Official Ruby Documentation](https://ruby-doc.org)
- [Ruby Style Guide](https://rubystyle.guide)
~~~

### Dynamic Content Generation

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

*But markdown is just text!?* Yes, but have you ever tried to render clean markdown from a lot of conditional logic? MDPhlex tames the mess with a simple and familiar API.

- **Component-based**: Build reusable Markdown with simple ruby classes
- **Dynamic Markdown**: Generate markdown from dynamic data
- **Composable**: Mix Phlex and MDPhlex components freely

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
