# MDPhlex

MDPhlex is a Phlex component for rendering Markdown. Write your Markdown in Ruby with Phlex's familiar syntax and render it as a Markdown string.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mdphlex'
```

## Basic Usage

Create an MDPhlex::MD component just like you would create a Phlex component:

```ruby
class HelloWorld < MDPhlex::MD
  def view_template
    h1 "Hello, World!"

    p "Welcome to MDPhlex - writing Markdown with Phlex syntax!"

    h2 "Features"

    ul do
      li "Write Markdown using Ruby"
      li do
        plain "Support for "
        strong "bold"
        plain ", "
        em "italic"
        plain ", and "
        code "inline code"
      end
      li "Full Phlex component composition"
    end

    p do
      plain "Check out the "
      a(href: "https://github.com/martinemde/mdphlex") { "MDPhlex repository" }
      plain " for more information."
    end
  end
end

# Render the component
puts HelloWorld.new.call
```

This outputs the following Markdown:

```markdown
# Hello, World!

Welcome to MDPhlex - writing Markdown with Phlex syntax!

## Features

- Write Markdown using Ruby
- Support for **bold**, *italic*, and `inline code`
- Full Phlex component composition

Check out the [MDPhlex repository](https://github.com/martinemde/mdphlex) for more information.
```

## Rendering MDPhlex inside Phlex::HTML

MDPhlex components can be seamlessly integrated into your Phlex::HTML views:

```ruby
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
```

## Why MDPhlex?

- **Component-based**: Build reusable Markdown components
- **Type-safe**: Get Ruby's type checking and IDE support
- **Composable**: Mix Phlex::HTML and MDPhlex components freely
- **Familiar**: Uses the same syntax as Phlex

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
