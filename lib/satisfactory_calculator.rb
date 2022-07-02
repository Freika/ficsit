# frozen_string_literal: true

require_relative "satisfactory_calculator/version"
require 'pry'
require 'terminal-table'
require 'json'

module SatisfactoryCalculator
  class Error < StandardError; end

  class Calc
    attr_reader :inputs
    attr_reader :tables

    def initialize(recipe_name, amount)
      @amount = amount
      @recipe_name = recipe_name
      @inputs = []
      @tables = []
    end

    def call
      recipe = recipes.find { |a| a['name'] == @recipe_name }

      machines = machines_amount(@amount, recipe['out'])
      @inputs << calculate_input(recipe, machines)

      inputs = @inputs.reverse.reject(&:empty?)

      puts draw_tables

      {
        name: recipe['name'],
        machines: machines,
        inputs: inputs
      }
    end

    def recipes
      file = File.open('lib/recipes.json')
      JSON.parse(file.read)
    end

    def machines_amount(amount, out)
      (amount / out).to_f
    end

    def calculate_input(recipe, machines)
      table_rows = []

      calculated = recipe['in'].flat_map do |input_resource|
        pieces_total = (machines * input_resource['pieces'])

        recipe_found = recipes.find { |a| a['name'] == input_resource['name'] }
        raise StandardError, "Recipe \"#{input_resource['name']}\" not found" if recipe_found.nil?

        machines_number = machines_amount(pieces_total, recipe_found['out'])
        result = {
          name: input_resource['name'],
          pieces_total: pieces_total,
          machines: machines_number
        }

        @inputs << calculate_input(recipe_found, machines_number)
        table_rows << table_row(input_resource['name'], pieces_total)

        result
      end

      table_data = {
        name: recipe['name'],
        rows: table_rows,
        machines: machines.truncate(2),
        output: (recipe['out'] * machines).truncate(3)
      }

      @tables << table_data

      calculated
    end

    def table_row(name, pieces_total)
      [name, pieces_total]
    end

    def draw_tables
      @tables.reverse.each do |data|
        next if data[:rows].empty?

        rows = data[:rows]
        rows << :separator
        rows << ['Machines', data[:machines]]
        rows << ['Output', data[:output]]

        puts Terminal::Table.new(
          title: data[:name],
          rows: rows
        )
      end
    end
  end
end
