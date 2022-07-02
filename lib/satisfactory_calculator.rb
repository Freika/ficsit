# frozen_string_literal: true

require_relative "satisfactory_calculator/version"
require 'pry'
require 'terminal-table'
require 'json'

module SatisfactoryCalculator
  class Error < StandardError; end

  class Calc
    attr_reader :inputs, :tables

    def initialize(recipe_name, amount, debug: false)
      @amount = amount
      @recipe_name = recipe_name
      @inputs = []
      @tables = []
      @debug = debug
    end

    def call
      recipe = resource(@recipe_name)

      machines = machines_amount(@amount, recipe['out'])
      @inputs << calculate_input(recipe, machines)

      inputs = @inputs.reverse.reject(&:empty?)

      puts draw_tables

      { name: recipe['name'], machines: machines, inputs: inputs } if @debug
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
        recipe_found = resource(input_resource['name'])
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
      [name, { value: pieces_total, alignment: :right }]
    end

    def draw_tables
      @tables.reverse.map do |data|
        next if data[:rows].empty?

        rows = data[:rows]
        rows << :separator
        rows << ['Machines', { value: data[:machines], alignment: :right }]
        rows << ['Output', { value: data[:output], alignment: :right }]

        Terminal::Table.new(title: data[:name], rows: rows, style: table_style)
      end
    end

    def resource(name)
      recipe = recipes.find { |a| a['name'] == name }

      raise StandardError, "Recipe \"#{name}\" not found" if recipe.nil?

      recipe
    end

    def table_style
      { border: :unicode_round, width: 40, padding_left: 3}
    end
  end
end
