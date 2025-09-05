# frozen_string_literal: true

test "renders h1 heading" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      h1 "Hello World"
    end
  end

  assert_equal example.new.call, "# Hello World\n"
end

test "renders h2 heading" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      h2 "Subheading"
    end
  end

  assert_equal example.new.call, "## Subheading\n"
end

test "renders h3 heading" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      h3 "Section"
    end
  end

  assert_equal example.new.call, "### Section\n"
end

test "renders h4-h6 headings" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      h4 "Level 4"
      h5 "Level 5"
      h6 "Level 6"
    end
  end

  assert_equal example.new.call, "#### Level 4\n##### Level 5\n###### Level 6\n"
end

test "renders paragraph" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p "This is a paragraph."
    end
  end

  assert_equal example.new.call, "This is a paragraph.\n\n"
end

test "renders strong text" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p do
        plain "This is "
        strong "bold"
        plain " text."
      end
    end
  end

  assert_equal example.new.call, "This is **bold** text.\n\n"
end

test "renders emphasized text" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p do
        plain "This is "
        em "italic"
        plain " text."
      end
    end
  end

  assert_equal example.new.call, "This is *italic* text.\n\n"
end

test "renders inline code" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p do
        plain "Use "
        code "puts 'hello'"
        plain " to print."
      end
    end
  end

  assert_equal example.new.call, "Use `puts 'hello'` to print.\n\n"
end

test "renders links" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p do
        a(href: "https://example.com") { "Click here" }
      end
    end
  end

  assert_equal example.new.call, "[Click here](https://example.com)\n\n"
end

test "separates multiple paragraphs with blank line" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p "First paragraph."
      p "Second paragraph."
    end
  end

  assert_equal example.new.call, "First paragraph.\n\nSecond paragraph.\n\n"
end

test "renders blockquotes" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      blockquote "This is a quote."
    end
  end

  assert_equal example.new.call, "> This is a quote.\n\n"
end

test "renders blockquotes with block content" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      blockquote do
        plain "This is a "
        strong "quoted"
        plain " text."
      end
    end
  end

  assert_equal example.new.call, "> This is a **quoted** text.\n\n"
end

test "renders multiline blockquotes" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      blockquote "Line 1\nLine 2\nLine 3"
    end
  end

  assert_equal example.new.call, "> Line 1\n> Line 2\n> Line 3\n\n"
end

test "renders code blocks" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      pre do
        plain "def hello\n  puts 'world'\nend"
      end
    end
  end

  assert_equal example.new.call, "```\ndef hello\n  puts 'world'\nend\n```\n\n"
end

test "renders code blocks with language" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      pre(language: "ruby") do
        plain "def hello\n  puts 'world'\nend"
      end
    end
  end

  assert_equal example.new.call, "```ruby\ndef hello\n  puts 'world'\nend\n```\n\n"
end

test "renders unordered lists" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      ul do
        li "First item"
        li "Second item"
        li "Third item"
      end
    end
  end

  assert_equal example.new.call, "- First item\n- Second item\n- Third item\n\n"
end

test "renders ordered lists" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      ol do
        li "First item"
        li "Second item"
        li "Third item"
      end
    end
  end

  assert_equal example.new.call, "1. First item\n2. Second item\n3. Third item\n\n"
end

test "renders nested lists" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      ul do
        li "Item 1"
        li do
          plain "Item 2"
          ul do
            li "Nested item 2.1"
            li "Nested item 2.2"
          end
        end
        li "Item 3"
      end
    end
  end

  assert_equal example.new.call, "- Item 1\n- Item 2\n  - Nested item 2.1\n  - Nested item 2.2\n- Item 3\n\n"
end

test "renders images" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      img(src: "https://example.com/image.jpg", alt: "Example image")
    end
  end

  assert_equal example.new.call, "![Example image](https://example.com/image.jpg)"
end

test "renders images without alt text" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      img(src: "https://example.com/image.jpg")
    end
  end

  assert_equal example.new.call, "![](https://example.com/image.jpg)"
end

test "renders horizontal rules" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p "Above the line"
      hr
      p "Below the line"
    end
  end

  assert_equal example.new.call, "Above the line\n\n---\n\nBelow the line\n\n"
end

test "renders line breaks" do
  example = Class.new(MDPhlex::MD) do
    def view_template
      p do
        plain "Line 1"
        br
        plain "Line 2"
      end
    end
  end

  assert_equal example.new.call, "Line 1  \nLine 2\n\n"
end

test "renders custom element registered with register_element" do
  example = Class.new(MDPhlex::MD) do
    register_element :system

    def view_template
      system { "System message" }
    end
  end

  assert_equal example.new.call, "<system>System message</system>"
end

test "renders custom element with attributes" do
  example = Class.new(MDPhlex::MD) do
    register_element :system

    def view_template
      system(type: "warning", level: "high") { "Alert!" }
    end
  end

  assert_equal example.new.call, '<system type="warning" level="high">Alert!</system>'
end

test "renders custom element within markdown context" do
  example = Class.new(MDPhlex::MD) do
    register_element :system

    def view_template
      p do
        plain "This is a "
        system { "system message" }
        plain " in a paragraph."
      end
    end
  end

  assert_equal example.new.call, "This is a <system>system message</system> in a paragraph.\n\n"
end

test "renders nested custom block elements" do
  example = Class.new(MDPhlex::MD) do
    register_block_element :system
    register_block_element :tools

    def view_template
      system do
        h1 "Main:"
        tools do
          ul do
            li "nested content 1"
            li "nested content 2"
          end
        end
      end
    end
  end

  assert_equal example.new.call, <<~XML
    <system>
    # Main:
    <tools>
    - nested content 1
    - nested content 2

    </tools>
    </system>
  XML
end

test "register_block_element vs register_element spacing" do
  example = Class.new(MDPhlex::MD) do
    register_element :inline_tag
    register_block_element :block_tag

    def view_template
      p do
        plain "Text with "
        inline_tag { "inline" }
        plain " content."
      end

      block_tag { p "Block content" }

      p "After block"
    end
  end

  assert_equal example.new.call, <<~MD
    Text with <inline-tag>inline</inline-tag> content.

    <block-tag>
    Block content

    </block-tag>
    After block

  MD
end

test "register_block_element with attributes" do
  example = Class.new(MDPhlex::MD) do
    register_block_element :section

    def view_template
      section(id: "main", class: "container") do
        h2 "Section Title"
        p "Section content"
      end
    end
  end

  assert_equal example.new.call, <<~MD
    <section id="main" class="container">
    ## Section Title
    Section content

    </section>
  MD
end

test "multiple register_block_elements" do
  example = Class.new(MDPhlex::MD) do
    register_block_element :article
    register_block_element :aside

    def view_template
      article do
        h1 "Main Article"
        p "Article content"
      end

      aside do
        h2 "Related"
        p "Sidebar content"
      end
    end
  end

  assert_equal example.new.call, <<~MD
    <article>
    # Main Article
    Article content

    </article>
    <aside>
    ## Related
    Sidebar content

    </aside>
  MD
end
