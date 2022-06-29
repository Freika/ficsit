# frozen_string_literal: true

require_relative "satisfactory_calculator/version"
require 'byebug'
require 'terminal-table'

module SatisfactoryCalculator
  class Error < StandardError; end

  class Calc
    attr_reader :inputs
    attr_reader :tables

    def initialize(amount)
      @amount = amount
      @inputs = []
      @tables = []
    end

    def call
      screws = recipes.find { |a| a[:name] == 'Screws' }

      machines = machines_amount(@amount, screws[:out])
      @inputs << calculate_input(screws, machines)

      inputs = @inputs.reverse.reject(&:empty?)

      @tables.each { |t| puts t }

      {
        name: screws[:name],
        machines: machines,
        inputs: inputs
      }
    end

    def recipes
      [
        { name: 'Screws', out: 40, in: [{ name: 'Iron rod', pieces: 10 }] },
        { name: 'Iron rod', out: 15, in: [{ name: 'Iron ingot', pieces: 15 }] },
        { name: 'Iron ingot', out: 30, in: [{ name: 'Iron', pieces: 30 }, { name: 'Copper', pieces: 30 }] },
        { name: 'Iron', out: 30, in: [] },
        { name: 'Copper', out: 30, in: [] }
      ]
    end

    def machines_amount(amount, out)
      (amount / out).to_f.round(2)
    end

    def calculate_input(recipe, machines)
      recipe[:in].flat_map do |input_resource|
        pieces_total = machines * input_resource[:pieces]

        recipe_found = recipes.find { |a| a[:name] == input_resource[:name] }
        machines_number = machines_amount(pieces_total, recipe_found[:out])
        result = {
          name: input_resource[:name],
          pieces_total: pieces_total.round(2),
          machines: machines_number
        }

        @inputs << calculate_input(recipe_found, machines_number)

        result
      end
    end
  end
end
