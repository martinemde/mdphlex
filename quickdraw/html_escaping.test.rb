# frozen_string_literal: true

test "markdown does not escape HTML entities" do
  component = Class.new(MDPhlex::MD) do
    def view_template
      p { "HTML tags: <strong>bold</strong> & <em>italic</em>" }
    end
  end

  output = component.new.call
  assert_equal output, "HTML tags: <strong>bold</strong> & <em>italic</em>\n\n"
end

test "markdown preserves raw HTML in plain text" do
  component = Class.new(MDPhlex::MD) do
    def view_template
      p do
        plain "Raw HTML: <div>content</div> & entities"
      end
    end
  end

  output = component.new.call
  assert_equal output, "Raw HTML: <div>content</div> & entities\n\n"
end

test "markdown preserves HTML in inline elements" do
  component = Class.new(MDPhlex::MD) do
    def view_template
      p do
        strong { "<b>nested</b> & more" }
        plain " "
        em { "<i>italic</i>" }
      end
    end
  end

  output = component.new.call
  assert_equal output, "**<b>nested</b> & more** *<i>italic</i>*\n\n"
end

test "custom elements do not escape attribute values" do
  component = Class.new(MDPhlex::MD) do
    register_block_element :custom_div, tag: "div"

    def view_template
      custom_div(class: "test & class", "data-value": "x > 5") do
        p { "Content" }
      end
    end
  end

  output = component.new.call
  assert_includes output, '<div class="test & class" data-value="x > 5">'
end

test "code blocks preserve HTML content" do
  component = Class.new(MDPhlex::MD) do
    def view_template
      pre(language: "html") do
        plain "<div class=\"example\">\n  <p>HTML code</p>\n</div>"
      end
    end
  end

  output = component.new.call
  expected = <<~MD
    ```html
    <div class="example">
      <p>HTML code</p>
    </div>
    ```

  MD
  assert_equal output, expected
end

test "code blocks with JSON.pretty_generate preserve quotes and special characters" do
  require "json"

  component = Class.new(MDPhlex::MD) do
    def view_template
      pre language: "json" do
        JSON.pretty_generate({ email: "user@example.com", password: "secure_password123" })
      end
    end
  end

  output = component.new.call
  expected = <<~MD
    ```json
    {
      "email": "user@example.com",
      "password": "secure_password123"
    }
    ```

  MD
  assert_equal output, expected
end

test "code blocks preserve complex JSON with special characters" do
  require "json"

  component = Class.new(MDPhlex::MD) do
    def view_template
      pre language: "json" do
        JSON.pretty_generate({
          users: [
            { name: "John & Jane", role: "admin" },
            { name: "Bob <Smith>", role: "user" },
          ],
          config: {
            api_key: "key-with-special-chars-!@#$%^&*()",
            html_template: "<div class=\"test\">Content</div>",
          },
        })
      end
    end
  end

  output = component.new.call
  expected = <<~MD
    ```json
    {
      "users": [
        {
          "name": "John & Jane",
          "role": "admin"
        },
        {
          "name": "Bob <Smith>",
          "role": "user"
        }
      ],
      "config": {
        "api_key": "key-with-special-chars-!@#$%^&*()",
        "html_template": "<div class=\\"test\\">Content</div>"
      }
    }
    ```

  MD
  assert_equal output, expected
end
