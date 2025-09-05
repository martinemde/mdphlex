# frozen_string_literal: true

require "phlex"

test "MDPhlex::MD component rendered inside Phlex::HTML component" do
  # Define a simple Markdown component
  markdown_component = Class.new(MDPhlex::MD) do
    def view_template
      h2 "Markdown Section"
      p "This is a paragraph with **bold** text."
      ul do
        li "First item"
        li "Second item"
      end
    end
  end

  # Define an HTML component that renders the Markdown component
  html_component = Class.new(Phlex::HTML) do
    def initialize(markdown_component)
      @markdown_component = markdown_component
    end

    def view_template
      article do
        h1 { "HTML Article" }
        div(class: "markdown-content") do
          plain render(@markdown_component.new)
        end
      end
    end
  end

  # Render and test
  output = html_component.new(markdown_component).call

  assert output.include?("<article>")
  assert output.include?("<h1>HTML Article</h1>")
  assert output.include?('<div class="markdown-content">')
  assert output.include?("## Markdown Section")
  assert output.include?("This is a paragraph with **bold** text.")
  assert output.include?("- First item")
  assert output.include?("- Second item")
  assert output.include?("</article>")
end

test "MDPhlex::MD component rendered inside Phlex::HTML without .new" do
  # Define a Markdown component that doesn't need initialization
  simple_markdown = Class.new(MDPhlex::MD) do
    def view_template
      h1 "About"
      p "This component can be rendered without calling .new"
    end
  end

  # HTML component that renders the class directly
  html_wrapper = Class.new(Phlex::HTML) do
    def initialize(markdown_class)
      @markdown_class = markdown_class
    end

    def view_template
      div(class: "wrapper") do
        # Render without .new - Phlex should automatically initialize
        plain render(@markdown_class)
      end
    end
  end

  output = html_wrapper.new(simple_markdown).call

  assert output.include?('<div class="wrapper">')
  assert output.include?("# About")
  assert output.include?("This component can be rendered without calling .new")
end

test "Phlex::HTML component rendered inside MDPhlex::MD component" do
  # Define an HTML component
  button_component = Class.new(Phlex::HTML) do
    def initialize(text:, variant: "primary")
      @text = text
      @variant = variant
    end

    def view_template
      button(type: "button", class: "btn btn-#{@variant}") { @text }
    end
  end

  # Define a Markdown component that renders HTML components
  markdown_component = Class.new(MDPhlex::MD) do
    def initialize(button_component)
      @button_component = button_component
    end

    def view_template
      h1 "Interactive Documentation"

      p "Here's an example of a button component:"

      # Render the HTML component directly
      render @button_component.new(text: "Click me!", variant: "primary")

      p "You can also use different variants:"

      render @button_component.new(text: "Warning", variant: "warning")
      render @button_component.new(text: "Danger", variant: "danger")
    end
  end

  # Render and test
  output = markdown_component.new(button_component).call

  assert output.include?("# Interactive Documentation")
  assert output.include?("Here's an example of a button component:")
  assert output.include?('<button type="button" class="btn btn-primary">Click me!</button>')
  assert output.include?("You can also use different variants:")
  assert output.include?('<button type="button" class="btn btn-warning">Warning</button>')
  assert output.include?('<button type="button" class="btn btn-danger">Danger</button>')
end

test "MDPhlex::MD component rendered inside another MDPhlex::MD component" do
  # Define a reusable Markdown component for code examples
  code_example = Class.new(MDPhlex::MD) do
    def initialize(title:, code:, language: "ruby")
      @title = title
      @code = code
      @language = language
    end

    def view_template
      h3 @title
      pre(language: @language) { plain @code }
    end
  end

  # Define a parent Markdown component that uses the code example component
  tutorial_component = Class.new(MDPhlex::MD) do
    def initialize(code_example_component)
      @code_example_component = code_example_component
    end

    def view_template
      h1 "MDPhlex Tutorial"

      p "Learn how to use MDPhlex for creating beautiful documentation."

      h2 "Examples"

      # Render child MDPhlex::MD components
      render @code_example_component.new(
        title: "Basic Usage",
        code: <<~RUBY
          class MyDoc < MDPhlex
            def view_template
              h1 "Hello World"
              p "This is MDPhlex!"
            end
          end
        RUBY
      )

      render @code_example_component.new(
        title: "Lists and Formatting",
        code: <<~RUBY
          ul do
            li "Item with **bold** text"
            li "Item with `code`"
          end
        RUBY
      )

      p "These examples show the flexibility of component composition."
    end
  end

  # Render and test
  output = tutorial_component.new(code_example).call

  assert output.include?("# MDPhlex Tutorial")
  assert output.include?("Learn how to use MDPhlex for creating beautiful documentation.")
  assert output.include?("## Examples")
  assert output.include?("### Basic Usage")
  assert output.include?("```ruby")
  assert output.include?('h1 "Hello World"')
  assert output.include?("### Lists and Formatting")
  assert output.include?('li "Item with **bold** text"')
  assert output.include?("These examples show the flexibility of component composition.")
end

test "Components yielding content blocks across Phlex::HTML and MDPhlex::MD" do
  # Define a card component that yields content
  card_component = Class.new(Phlex::HTML) do
    def initialize(title:)
      @title = title
    end

    def view_template
      div(class: "card") do
        h2(class: "card-title") { @title }
        div(class: "card-content") do
          yield
        end
      end
    end
  end

  # MDPhlex::MD component that uses the card and passes content
  markdown_component = Class.new(MDPhlex::MD) do
    def initialize(card_class)
      @card_class = card_class
    end

    def view_template
      h1 "Documentation with Cards"

      # Render HTML component with a content block
      render @card_class.new(title: "Important Note") do
        p "This is **important** information inside a card."
        ul do
          li "First point"
          li "Second point"
        end
      end
    end
  end

  output = markdown_component.new(card_component).call

  assert output.include?("# Documentation with Cards")
  assert output.include?('<div class="card">')
  assert output.include?('<h2 class="card-title">Important Note</h2>')
  assert output.include?('<div class="card-content">')
  assert output.include?("This is **important** information inside a card.")
  assert output.include?("- First point")
end

test "Interface yielding pattern between MDPhlex::MD and Phlex::HTML" do
  # Define a nav component with interface yielding
  nav_component = Class.new(Phlex::HTML) do
    def view_template(&)
      nav(class: "special-nav", &)
    end

    def item(href, &)
      a(class: "nav-item", href:, &)
    end

    def divider
      span(class: "nav-divider") { "|" }
    end
  end

  # MDPhlex::MD component that uses the nav interface
  docs_layout = Class.new(MDPhlex::MD) do
    def initialize(nav_class)
      @nav_class = nav_class
    end

    def view_template
      h1 "Site Navigation Example"

      p "Here's how to use the nav component:"

      # Use the yielded interface
      render @nav_class.new do |nav|
        nav.item("/") { "Home" }
        nav.item("/docs") { "Documentation" }
        nav.divider
        nav.item("/about") { "About" }
      end

      p "The nav component yields an interface for building navigation."
    end
  end

  output = docs_layout.new(nav_component).call

  assert output.include?("# Site Navigation Example")
  assert output.include?('<nav class="special-nav">')
  assert output.include?('<a class="nav-item" href="/">Home</a>')
  assert output.include?('<a class="nav-item" href="/docs">Documentation</a>')
  assert output.include?('<span class="nav-divider">|</span>')
  assert output.include?('<a class="nav-item" href="/about">About</a>')
end

test "Conditional rendering with render? method" do
  # HTML component with conditional rendering
  notification_badge = Class.new(Phlex::HTML) do
    def initialize(count:)
      @count = count
    end

    def view_template
      span(class: "badge") { @count }
    end

    def render?
      @count > 0
    end
  end

  # MDPhlex::MD component that conditionally renders the badge
  user_profile = Class.new(MDPhlex::MD) do
    def initialize(badge_class, notifications_count)
      @badge_class = badge_class
      @notifications_count = notifications_count
    end

    def view_template
      h1 "User Profile"

      p do
        plain "Notifications "
        render @badge_class.new(count: @notifications_count)
      end
    end
  end

  # Test with notifications
  output_with = user_profile.new(notification_badge, 5).call
  assert output_with.include?("# User Profile")
  assert output_with.include?("Notifications <span class=\"badge\">5</span>")

  # Test without notifications
  output_without = user_profile.new(notification_badge, 0).call
  assert output_without.include?("# User Profile")
  assert output_without.include?("Notifications ")
  assert !output_without.include?("badge")
end
