#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/mdphlex"

# Example: Creating structured LLM prompts with custom XML-style tags
class LLMPrompt < MDPhlex::MD
  # Register custom block elements for LLM prompt structure
  register_block_element :system
  register_block_element :tools
  register_block_element :tool
  register_element :description
  register_block_element :parameters
  register_block_element :param
  register_block_element :examples
  register_block_element :example
  register_block_element :user
  register_block_element :assistant
  register_block_element :context
  register_block_element :constraints

  def initialize(task:, tools: [], examples: [], context: nil, constraints: [])
    @task = task
    @tools = tools
    @examples = examples
    @context = context
    @constraints = constraints
  end

  def view_template
    # System instructions
    system do
      plain "You are an AI assistant specialized in #{@task}."
      plain "\n"
      plain "You have access to tools and should use them when appropriate to help the user."
      plain "\n"
      plain "Always be helpful, accurate, and follow the constraints provided."
    end

    plain "\n"

    # Context section
    if @context
      context do
        plain @context
      end
      plain "\n"
    end

    # Constraints
    if @constraints.any?
      constraints do
        @constraints.each do |constraint|
          plain "- #{constraint}\n"
        end
      end
      plain "\n"
    end

    # Available tools
    if @tools.any?
      tools do
        @tools.each do |tool_def|
          tool name: tool_def[:name], category: tool_def[:category] do
            description { plain tool_def[:description] }

            if tool_def[:parameters]&.any?
              parameters do
                tool_def[:parameters].each do |param|
                  param name: param[:name], type: param[:type], required: param[:required].to_s do
                    plain param[:description]
                  end
                end
              end
            end
          end
        end
      end
      plain "\n"
    end

    # Examples
    if @examples.any?
      examples do
        @examples.each_with_index do |ex, i|
          example id: (i + 1).to_s do
            user { plain ex[:user] }
            assistant { plain ex[:assistant] }
          end
        end
      end
      plain "\n"
    end

    # Instructions footer
    h2 "Instructions"

    p "When responding to user queries, follow the system guidelines above and use the available tools as needed."
  end
end

# Example usage
if __FILE__ == $0
  prompt = LLMPrompt.new(
    task: "code review and refactoring",
    context: "The user is working on a Ruby on Rails application and needs help improving code quality.",
    constraints: [
      "Focus on Ruby idioms and best practices",
      "Consider performance implications",
      "Suggest tests when appropriate",
      "Keep explanations clear and concise",
    ],
    tools: [
      {
        name: "analyze_code",
        category: "analysis",
        description: "Analyzes code for potential improvements, security issues, and best practices",
        parameters: [
          {
            name: "code",
            type: "string",
            required: true,
            description: "The code snippet to analyze",
          },
          {
            name: "language",
            type: "string",
            required: false,
            description: "Programming language (defaults to auto-detect)",
          },
          {
            name: "focus_areas",
            type: "array",
            required: false,
            description: "Specific areas to focus on: performance, security, readability, testing",
          },
        ],
      },
      {
        name: "suggest_refactoring",
        category: "refactoring",
        description: "Provides specific refactoring suggestions with before/after examples",
        parameters: [
          {
            name: "code",
            type: "string",
            required: true,
            description: "The code to refactor",
          },
          {
            name: "refactoring_type",
            type: "string",
            required: false,
            description: "Type of refactoring: extract_method, simplify_conditionals, remove_duplication",
          },
        ],
      },
    ],
    examples: [
      {
        user: "Review this Ruby method for improvements:\n```ruby\ndef process_items(items)\n  results = []\n  items.each do |item|\n    if item.valid?\n      results << item.process\n    end\n  end\n  results\nend\n```",
        assistant: "I'll analyze your Ruby method and suggest improvements.\n\nThe method can be refactored to be more idiomatic and concise using Ruby's enumerable methods:\n\n```ruby\ndef process_items(items)\n  items.select(&:valid?).map(&:process)\nend\n```\n\nKey improvements:\n1. **Use `select` and `map`**: More idiomatic than manual array building\n2. **Symbol-to-proc syntax**: `&:valid?` is cleaner than blocks\n3. **Method chaining**: Reads naturally left-to-right\n4. **No temporary variable**: Eliminates the `results` array\n\nThis refactored version is more functional, easier to test, and clearly expresses the intent.",
      },
    ]
  )

  # Generate the output once and store it
  output = prompt.call

  # Print to console
  puts output

  # Also save the output to a file for reference
  File.write(
    File.join(File.dirname(__FILE__), "llm_prompt_output.md"),
    output
  )

  puts "\n---"
  puts "Output saved to examples/llm_prompt_output.md"
end
