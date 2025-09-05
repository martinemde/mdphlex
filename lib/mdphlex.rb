# frozen_string_literal: true

require "phlex"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("mdphlex" => "MDPhlex", "md" => "MD")
loader.setup

module MDPhlex
end
