# frozen_string_literal: true

require_relative "satisfactory_calculator/version"
require 'byebug'

module SatisfactoryCalculator
  class Error < StandardError; end

  module_function

  def call(amount)
    screws = SatisfactoryCalculator.recipes.find { |a| a[:name] == 'Screws' }

    machines = machines_amount(amount, screws[:out])
    {
      name: screws[:name],
      input: calculate_input(screws[:in], machines),
      machines: machines
    }
  end

  def recipes
    [
      { name: 'Screws', out: 40, in: [{ name: 'Iron rod', pieces: 10 }] },
      { name: 'Iron rod', out: 15, in: [{ name: 'Iron ingot', pieces: 15 }] },
      { name: 'Iron ingot', out: 30, in: [{ name: 'Iron', pieces: 30 }] },
      { name: 'Iron', out: 30, in: [] }
    ]
  end

  def machines_amount(amount, out)
    (amount / out).to_f.round(2)
  end

  def calculate_input(incoming_resource, machines)
    incoming_resource.map do |input_resource|
      pieces_total = machines * input_resource[:pieces]

      recipe = recipes.find { |a| a[:name] == input_resource[:name] }
      {
        name: input_resource[:name],
        pieces_total: pieces_total,
        machines: machines_amount(pieces_total, recipe[:out]),
        input: calculate_input(recipe[:in], machines_amount(pieces_total, recipe[:out]))
      }
    end
  end
end
