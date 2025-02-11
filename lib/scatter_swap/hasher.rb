# frozen_string_literal: true

require 'scatter_swap/swapper'

module ScatterSwap
  class Hasher
    DIGITS = (0..9).to_a.freeze

    attr_accessor :working_array

    def initialize(original_integer, spin = 0, length = 10)
      @original_integer = original_integer
      @spin = spin
      @length = length
      zero_pad = original_integer.to_s.rjust(length, '0')
      @working_array = zero_pad.chars.map(&:to_i)
    end

    # obfuscates an integer up to @length digits in length
    def hash
      swap
      scatter
      @working_array.join
    end

    # de-obfuscates an integer
    def reverse_hash
      unscatter
      unswap
      @working_array.join
    end

    def swapper_map(index)
      Swapper.instance(@spin).generate(index)
    end

    # Using a unique map for each of the ten places,
    # we swap out one number for another
    def swap
      @working_array = @working_array.map.with_index do |digit, index|
        swapper_map(index)[digit]
      end
    end

    # Reverse swap
    def unswap
      @working_array = @working_array.map.with_index do |digit, index|
        swapper_map(index).rindex(digit)
      end
    end

    # Rearrange the order of each digit in a reversible way by using the
    # sum of the digits (which doesn't change regardless of order)
    # as a key to record how they were scattered
    def scatter
      sum_of_digits = @working_array.inject(:+).to_i
      @working_array = @length.times.map do
        @working_array.rotate!(@spin ^ sum_of_digits).pop
      end
    end

    # Reverse the scatter
    def unscatter
      scattered_array = @working_array
      sum_of_digits = scattered_array.inject(:+).to_i
      @working_array = []
      @working_array.tap do |unscatter|
        @length.times do
          unscatter.push scattered_array.pop
          unscatter.rotate! (sum_of_digits ^ @spin) * -1
        end
      end
    end
  end
end
