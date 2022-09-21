require 'hashie'

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
      @sankey = []
    end

    def call
      data = calculate_resources
      data[:total_data] = total_raw_resources(data)
      data[:sankey] = finalize_sankey
      data
    end

    private

    def calculate_resources
      main_recipe = resource(@recipe_name)
      machines    = machines_amount(@amount, main_recipe['out'])

      @inputs << calculate_input(main_recipe, machines)

      inputs = @inputs.reverse.reject(&:empty?)

      {
        name: main_recipe['name'],
        machines: machines,
        inputs: inputs
      }
    end

    def recipes
      return @recipes if defined?(@recipes)

      file_path = File.join(File.dirname(__FILE__), '../recipes.json')
      @recipes = JSON.parse(File.read(file_path))
    end

    def machines_amount(amount, out)
      return 0 if out.empty? || out.find { |c| c['pieces'] == 0 }&.any?

      amount.to_f / out.first['pieces']
    end

    def calculate_input(recipe, machines)
      table_rows = []

      calculated = recipe['in'].flat_map do |input_resource|
        pieces_total = (machines * input_resource['pieces'])
        recipe_found = resource(input_resource['name'])
        machines_number = machines_amount(pieces_total, recipe_found['out'])
        inputs = calculate_input(recipe_found, machines_number)

        result = {
          name: input_resource['name'],
          pieces_total: pieces_total,
          machines: machines_number,
          inputs: inputs
        }

        sankey = { source: input_resource['name'], target: recipe['name'], value: pieces_total }
        @sankey << sankey

        # @inputs << inputs
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

    def total_raw_resources(total_data)
      total_data.extend(Hashie::Extensions::DeepFind)

      flat_data = total_data.deep_select(:inputs).flatten

      flat_data.group_by { |a| a[:name] }.map do |name, data|
        { name: name, pieces_total: data.sum { |a| a[:pieces_total] } }
      end
    end

    def finalize_sankey
      # I just want to play Satisfactory already but I have to finish my
      # calculator first or I will be irritated because I'll have to use
      # Google Sheets for calculations again and it's not scalable.
      resources = (@sankey.map { |r| r[:source] } + @sankey.map { |r| r[:target] }).uniq.sort
      nodes = resources.map { |name| { name: name } }

      replacer = {}
      nodes.each.with_index { |resource, index| replacer[resource[:name]] = index }

      links = @sankey.each do |resource|
        original_source = resource[:source]
        original_target = resource[:target]
        resource[:source] = replacer[original_source]
        resource[:target] = replacer[original_target]
      end

      { nodes: nodes, links: links }
    end
  end
end
