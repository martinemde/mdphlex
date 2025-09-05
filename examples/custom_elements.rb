#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/mdphlex"
require "json"

# Example: Creating custom block elements for specialized markdown output
class DocumentationTemplate < MDPhlex::MD
  # Register custom elements for API documentation
  register_block_element :api_endpoint
  register_block_element :request
  register_block_element :response
  register_block_element :warning
  register_block_element :note
  register_block_element :deprecated

  def initialize(endpoint_name:, method:, path:)
    @endpoint_name = endpoint_name
    @method = method
    @path = path
  end

  def view_template
    h1 "API Documentation: #{@endpoint_name}"

    api_endpoint method: @method, path: @path do
      h2 "Overview"
      p "This endpoint handles user authentication and returns a JWT token."

      warning do
        p "This endpoint rate limits requests to 10 per minute per IP address."
      end

      h2 "Request"

      request do
        h3 "Headers"
        pre do
          <<~HEADERS
            Content-Type: application/json
            Accept: application/json
          HEADERS
        end

        h3 "Body"
        pre language: "json" do
          JSON.pretty_generate({ email: "user@example.com", password: "secure_password123" })
        end
      end

      h2 "Response"

      response status: "200" do
        h3 "Success Response"
        pre language: "json" do
          plain JSON.pretty_generate({
            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            user: {
              id: 123,
              email: "user@example.com",
              name: "John Doe",
            },
          })
        end
      end

      response status: "401" do
        h3 "Authentication Failed"
        pre language: "json" do
          JSON.pretty_generate({
            error: "Invalid credentials",
          })
        end
      end

      note do
        p "The JWT token expires after 24 hours. Use the refresh endpoint to get a new token."
      end

      deprecated version: "2.0" do
        p "The 'username' field in the request body is deprecated. Use 'email' instead."
      end
    end
  end
end

# Example usage
if __FILE__ == $0
  doc = DocumentationTemplate.new(
    endpoint_name: "User Login",
    method: "POST",
    path: "/api/v1/auth/login"
  )

  output = doc.call
  puts output

  # Save to file
  File.write(
    File.join(File.dirname(__FILE__), "custom_elements_output.md"),
    output
  )

  puts "\n---"
  puts "Output saved to examples/custom_elements_output.md"
end
