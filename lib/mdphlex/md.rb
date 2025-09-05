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

        if attributes.length > 0
          attributes.each do |key, value|
            buffer << " #{key}=\"#{value}\""
          end
        end

        buffer << ">\n"

        # Render content if block given
        if block
          __yield_content__(&block)
        end

        # Render closing tag - always followed by newline for block elements
        buffer << "</#{tag}>\n"

        nil
      end
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

      if block_given?
        # Save current position to capture content
        start_pos = buffer.length
        __yield_content__(&)
        # Extract the content that was added
        captured = buffer[start_pos..]
        # Remove it from buffer to re-add with > prefix
        buffer.slice!(start_pos..)

        # Add > prefix to each line
        captured.lines.each do |line|
          buffer << "> " << line
        end
      else
        content.to_s.lines.each do |line|
          buffer << "> " << line
        end
      end

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
      buffer << "\n" if @_list_type.length > 0 && buffer.length > 0 && !buffer.end_with?("\n")

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
      buffer << "\n" if @_list_type.length > 0 && buffer.length > 0 && !buffer.end_with?("\n")

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
      list_depth = @_list_type.length

      # Add indentation for nested lists
      buffer << ("  " * [list_depth - 1, 0].max)

      # Add list marker
      if @_list_type.last == :ol
        @_ol_counter ||= []
        @_ol_counter[-1] += 1
        buffer << "#{@_ol_counter.last}. "
      else
        buffer << "- "
      end

      if block_given?
        # Mark position before yielding content
        start_pos = buffer.length
        __yield_content__(&)
        # Only add newline if we haven't already ended with one
        # (nested lists already add their trailing newline)
        buffer << "\n" unless buffer.end_with?("\n")
      else
        buffer << content.to_s if content
        buffer << "\n"
      end

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
      state = @_state
      return true unless state.should_render?

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

    # Override __implicit_output__ to avoid HTML escaping
    private def __implicit_output__(content)
      state = @_state
      return true unless state.should_render?

      case content
      when Phlex::SGML::SafeObject
        state.buffer << content.to_s
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
