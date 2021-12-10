defmodule Zenflows.Valflow.Measure.Type do
@moduledoc "GraphQL types of Measures."

use Absinthe.Schema.Notation

alias Zenflows.Valflow.Measure.Resolv

@has_numerical_value """
A number representing the quantity, will be paired with a unit.
"""
@has_unit "A unit of measure."

@desc """
Semantic meaning for measurements: binds a quantity to its measurement
unit.  See http://www.qudt.org/pages/QUDToverviewPage.html .
"""
object :measure do
	field :id, non_null(:id)

	@desc @has_numerical_value
	field :has_numerical_value, non_null(:float)

	@desc @has_unit
	field :has_unit, non_null(:unit), resolve: &Resolv.has_unit/3
end

@desc """
Mutation input structure for defining measurements.  Should be nulled
if not present, rather than empty.
"""
object :imeasure, name: "IMeasure" do
	@desc @has_numerical_value
	field :has_numerical_value, non_null(:float)

	@desc "(`Unit`) " <> @has_unit
	field :has_unit, non_null(:id)
end
end
