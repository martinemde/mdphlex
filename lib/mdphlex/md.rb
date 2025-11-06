# frozen_string_literal: true

require "phlex"

module MDPhlex
  class MD < Phlex::SGML
    extend Phlex::SGML::Elements

    # Register a block-level custom element that ensures proper newlines
    def self.register_block_element(method_name, tag: method_name.to_s.tr("_", "-"))
      define_method(method_name) do |**attributes, &block|
        state = @_state
        buffer = state.buffer

        unless state.should_render?
          __yield_content__(&block) if block
          return nil
        end

        # Render the opening tag - always followed by newline
        buffer << "<#{tag}"

        attributes.each do |key, value|
          buffer << " #{key}=\"#{value}\""
        end

        buffer << ">\n"

        # Render content if block given
        __yield_content__(&block) if block

        # Render closing tag - always followed by newline for block elements
        buffer << "</#{tag}>\n"

        nil
      end
    end

    # Render the markdown to a String using the Rails 8.1 standard to_markdown alias
    def to_markdown
      call
    end

    def h1(content = nil, &)
      heading(1, content, &)
    end

    def h2(content = nil, &)
      heading(2, content, &)
    end

    def h3(content = nil, &)
      heading(3, content, &)
    end

    def h4(content = nil, &)
      heading(4, content, &)
    end

    def h5(content = nil, &)
      heading(5, content, &)
    end

    def h6(content = nil, &)
      heading(6, content, &)
    end

    def p(content = nil, &)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer

      if block_given?
        __yield_content__(&)
      elsif content
        buffer << content.to_s
      end

      buffer << "\n\n"
      nil
    end

    def strong(content = nil, &)
      wrap_inline("**", content, &)
    end

    def em(content = nil, &)
      wrap_inline("*", content, &)
    end

    def code(content = nil, &)
      wrap_inline("`", content, &)
    end

    def a(href: nil, **attributes, &)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      buffer << "["

      __yield_content__(&) if block_given?

      buffer << "]("
      buffer << href.to_s if href
      buffer << ")"
      nil
    end

    def plain(content)
      state = @_state
      return unless state.should_render?

      state.buffer << content.to_s
      nil
    end

    def blockquote(content = nil, &)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer

      # Capture content from block or use provided content
      text = if block_given?
        start_pos = buffer.length
        __yield_content__(&)
        captured = buffer[start_pos..]
        buffer.slice!(start_pos..)
        captured
      else
        content.to_s
      end

      # Add > prefix to each line
      text.lines.each { |line| buffer << "> " << line }
      buffer << "\n\n"
      nil
    end

    def pre(language: nil, &)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      buffer << "```"
      buffer << language.to_s if language
      buffer << "\n"

      __yield_content__(&) if block_given?

      buffer << "\n```\n\n"
      nil
    end

    def ul(&)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      @_list_type ||= []

      # If we're in a list item and there's already content, add a newline
      buffer << "\n" if @_list_type.any? && buffer.length > 0 && !buffer.end_with?("\n")

      @_list_type.push(:ul)

      __yield_content__(&) if block_given?

      @_list_type.pop
      # Only add extra newline at the end of top-level lists
      buffer << "\n" if @_list_type.empty?
      nil
    end

    def ol(&)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      @_list_type ||= []

      # If we're in a list item and there's already content, add a newline
      buffer << "\n" if @_list_type.any? && buffer.length > 0 && !buffer.end_with?("\n")

      @_list_type.push(:ol)
      @_ol_counter ||= []
      @_ol_counter.push(0)

      __yield_content__(&) if block_given?

      @_list_type.pop
      @_ol_counter.pop
      # Only add extra newline at the end of top-level lists
      buffer << "\n" if @_list_type.empty?
      nil
    end

    def li(content = nil, &)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      @_list_type ||= []
      list_indent = @_list_type.length - 1

      buffer << ("  " * list_indent) if list_indent.positive?

      # Add list marker
      if @_list_type.last == :ol
        @_ol_counter ||= []
        @_ol_counter[-1] += 1
        buffer << "#{@_ol_counter.last}. "
      else
        buffer << "- "
      end

      if block_given?
        __yield_content__(&)
      else
        buffer << content.to_s
      end

      buffer << "\n" unless buffer.end_with?("\n")

      nil
    end

    def img(src: nil, alt: nil, **attributes)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      buffer << "!["
      buffer << alt.to_s if alt
      buffer << "]("
      buffer << src.to_s if src
      buffer << ")"
      nil
    end

    def hr(**attributes)
      state = @_state
      return unless state.should_render?

      state.buffer << "---\n\n"
      nil
    end

    def br
      state = @_state
      return unless state.should_render?

      state.buffer << "  \n"
      nil
    end

    private def heading(level, content = nil, &)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      buffer << ("#" * level) << " "

      if block_given?
        __yield_content__(&)
      elsif content
        buffer << content.to_s
      end

      buffer << "\n"
      nil
    end

    private def wrap_inline(marker, content = nil, &)
      state = @_state
      return unless state.should_render?

      buffer = state.buffer
      buffer << marker

      if block_given?
        __yield_content__(&)
      elsif content
        buffer << content.to_s
      end

      buffer << marker
      nil
    end

    # Override __text__ to avoid HTML escaping since markdown allows raw HTML
    private def __text__(content)
      __render_content__(content)
    end

    # Override __implicit_output__ to avoid HTML escaping
    private def __implicit_output__(content)
      __render_content__(content, safe_object: true)
    end

    # Shared helper for rendering content without HTML escaping
    private def __render_content__(content, safe_object: false)
      state = @_state
      return true unless state.should_render?

      # Handle SafeObject only if safe_object flag is true
      if safe_object && content.is_a?(Phlex::SGML::SafeObject)
        state.buffer << content.to_s
        return true
      end

      case content
      when String
        state.buffer << content
      when Symbol
        state.buffer << content.name
      when nil
        nil
      else
        if (formatted_object = format_object(content))
          state.buffer << formatted_object
        else
          return false
        end
      end

      true
    end
  end
end
