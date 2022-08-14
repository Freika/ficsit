module Ficsit
  class Calc
    attr_reader :inputs, :tables

    RAW_RESOURCES = [
      'Iron', 'Copper', 'Coal', 'Caterium', 'Limestone',
      'Crude Oil', 'Heavy Oil Residue'
    ].freeze

    def initialize(recipe_name, amount, debug: false)
      @amount = amount
      @recipe_name = recipe_name
      @inputs = []
      @tables = []
      @debug = debug
    end

    def call
      recipe    = resource(@recipe_name)
      machines  = machines_amount(@amount, recipe['out'])

      @inputs << calculate_input(recipe, machines)

      inputs = @inputs.reverse.reject(&:empty?)

      { name: recipe['name'], machines: machines, inputs: inputs }
    end

    def recipes
      file_path = File.join(File.dirname(__FILE__), 'lib/recipes.json')
      @recipes ||= JSON.parse(File.read(file_path ))
    end

    def machines_amount(amount, out)
      return 0 if out.empty?

      amount.to_f / out.first['pieces']
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
        table_rows << table_row(input_resource['name'], pieces_total.truncate(2))

        result
      end

      form_table_data(recipe, table_rows, machines)

      calculated
    end

    def table_row(name, pieces_total)
      [name, { value: pieces_total, alignment: :right }]
    end

    def resource(name)
      recipe = recipes.find { |a| a['name'] == name }

      raise StandardError, "Recipe \"#{name}\" not found" if recipe.nil?

      recipe
    end

    def form_table_data(recipe, table_rows, machines)
      table_data = {
        name: recipe['name'],
        rows: table_rows,
        machines: machines.truncate(2),
        output: recipe['out'].map do |r|
          { name: r['name'], pieces: (r['pieces'] * machines).truncate(3) }
        end
      }

      @tables << table_data
    end
  end
end
