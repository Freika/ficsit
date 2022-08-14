module Ficsit
  class Table
    def initialize(recipe_name, amount, debug: false)
      @calculator = Calc.new(recipe_name, amount, debug: debug)
      @tables = @calculator.tables
      @total_data = @calculator.call
    end

    def call
      puts draw_tables
      puts '=========================================================='
      puts total_raw_resources_table
      puts @total_data if @debug
    end

    def draw_tables
      @tables.reverse.map do |data|
        next if data[:rows].empty?

        rows = data[:rows]
        rows << :separator
        rows << ['Machines', { value: data[:machines], alignment: :right }]
        data[:output].each do |output|
          rows << ["Out #{output[:name]}", { value: output[:pieces], alignment: :right }]
        end

        Terminal::Table.new(title: data[:name], rows: rows, style: table_style)
      end
    end

    def total_raw_resources_table
      rows = @total_data[:total_data].map do |resource|
        [resource[:name], { value: resource[:pieces_total], alignment: :right }]
      end

      Terminal::Table.new(title: 'Total Resources', rows: rows, style: table_style)
    end

    def table_style
      { border: :unicode_round, width: 50, padding_left: 3 }
    end

    def recipes
      @recipes ||= JSON.parse(File.read('lib/recipes.json'))
    end
  end
end
