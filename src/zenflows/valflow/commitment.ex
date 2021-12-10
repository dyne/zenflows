defmodule Zenflows.Valflow.Commitment do
@moduledoc """
A planned economic flow that has been promised by an agent to another
agent.
"""

use Zenflows.Ecto.Schema

alias Zenflows.Valflow.{
	ActionEnum,
	Agent,
	Agreement,
	EconomicResource,
	Measure,
	Plan,
	Process,
	ResourceSpecification,
	SpatialThing,
	Validate,
}

@type t() :: %__MODULE__{
	action: ActionEnum.t(),
	provider: Agent.t(),
	receiver: Agent.t(),
	input_of: Process.t() | nil,
	output_of: Process.t() | nil,
	resource_classified_as: [String.t()] | nil,
	resource_conforms_to: ResourceSpecification.t() | nil,
	resource_inventoried_as: EconomicResource.t() | nil,
	resource_quantity: Measure.t() | nil,
	effort_quantity: Measure.t() | nil,
	has_beginning: DateTime.t() | nil,
	has_end: DateTime.t() | nil,
	has_point_in_time: DateTime.t() | nil,
	due: DateTime.t() | nil,
	created: DateTime.t() | nil,
	finished: boolean(),
	note: String.t() | nil,
	# in_scope_of:
	agreed_in: String.t() | nil,
	independent_demand_of: Plan.t() | nil,
	at_location: SpatialThing.t() | nil,
	clause_of: Agreement.t() | nil,
}

schema "vf_commitment" do
	field :action, ActionEnum
	belongs_to :provider, Agent
	belongs_to :receiver, Agent
	belongs_to :input_of, Process
	belongs_to :output_of, Process
	field :resource_classified_as, {:array, :string}
	belongs_to :resource_conforms_to, ResourceSpecification
	belongs_to :resource_inventoried_as, EconomicResource
	belongs_to :resource_quantity, Measure
	belongs_to :effort_quantity, Measure
	field :has_beginning, :utc_datetime_usec
	field :has_end, :utc_datetime_usec
	field :has_point_in_time, :utc_datetime_usec
	field :due, :utc_datetime_usec
	timestamps(inserted_at: :created, updated_at: false)
	field :finished, :boolean, default: false
	field :note, :string
	# field :in_scope_of
	field :agreed_in, :string
	belongs_to :independent_demand_of, Plan
	belongs_to :at_location, SpatialThing
	belongs_to :clause_of, Agreement
end

@reqr ~w[action provider_id receiver_id]a
@cast @reqr ++ ~w[
	input_of_id output_of_id resource_classified_as
	resource_conforms_to_id resource_inventoried_as_id
	resource_quantity_id effort_quantity_id
	has_beginning has_end has_point_in_time due
	finished note agreed_in
	independent_demand_of_id at_location_id clause_of_id
]a # in_scope_of_id

@doc false
@spec chset(Schema.t(), params()) :: Changeset.t()
def chset(schema \\ %__MODULE__{}, params) do
	schema
	|> Changeset.cast(params, @cast)
	|> Changeset.validate_required(@reqr)
	|> datetime_check()
	|> resource_check()
	|> Validate.note(:note)
	|> Validate.class(:resource_classified_as)
	|> Changeset.assoc_constraint(:provider)
	|> Changeset.assoc_constraint(:receiver)
	|> Changeset.assoc_constraint(:input_of)
	|> Changeset.assoc_constraint(:output_of)
	|> Changeset.assoc_constraint(:resource_conforms_to)
	|> Changeset.assoc_constraint(:resource_inventoried_as)
	|> Changeset.assoc_constraint(:resource_quantity)
	|> Changeset.assoc_constraint(:effort_quantity)
	|> Changeset.assoc_constraint(:independent_demand_of)
	|> Changeset.assoc_constraint(:at_location)
	|> Changeset.assoc_constraint(:clause_of)
end

# Validate that either :has_point_in_time, :has_beginning, :has_end,
# or :due is provided and that :has_point_in_time and (:has_beginning
# and/or :has_end) are mutually exclusive.
@spec datetime_check(Changeset.t()) :: Changeset.t()
defp datetime_check(cset) do
	# credo:disable-for-previous-line Credo.Check.Refactor.CyclomaticComplexity

	{data_point, chng_point, field_point} =
		case Changeset.fetch_field(cset, :has_point_in_time) do
			{:data, x} -> {x, nil, x}
			{:changes, x} -> {nil, x, x}
		end
	{data_begin, chng_begin, field_begin} =
		case Changeset.fetch_field(cset, :has_beginning) do
			{:data, x} -> {x, nil, x}
			{:changes, x} -> {nil, x, x}
		end
	{data_end, chng_end, field_end} =
		case Changeset.fetch_field(cset, :has_end) do
			{:data, x} -> {x, nil, x}
			{:changes, x} -> {nil, x, x}
		end
	field_due = Changeset.get_field(cset, :due)

	cond do
		data_point && chng_begin ->
			msg = "has_beginning is not allowed in this record"
			Changeset.add_error(cset, :has_beginning, msg)

		data_point && chng_end ->
			msg = "has_end is not allowed in this record"
			Changeset.add_error(cset, :has_end, msg)

		(data_begin || data_end) && chng_point ->
			msg = "has_point_in_time is not allowed in this record"
			Changeset.add_error(cset, :has_point_in_time, msg)

		chng_point && chng_begin ->
			msg = "has_point_in_time and has_beginning are mutually exclusive"

			cset
			|> Changeset.add_error(:has_point_in_time, msg)
			|> Changeset.add_error(:has_beginning, msg)

		chng_point && chng_end ->
			msg = "has_point_in_time and has_end are mutually exclusive"

			cset
			|> Changeset.add_error(:has_point_in_time, msg)
			|> Changeset.add_error(:has_end, msg)

		field_point || field_begin || field_end || field_due ->
			cset

		true ->
			msg = "hasBeginning or hasEnd or hasPointInTime or due is required"

			cset
			|> Changeset.add_error(:has_point_in_time, msg)
			|> Changeset.add_error(:has_beginning, msg)
			|> Changeset.add_error(:has_end, msg)
			|> Changeset.add_error(:due, msg)
	end
end

# Validate mutual exclusivity of having an actual resource or its
# specification.
# In other words, forbid :resource_conforms_to and
# :resource_inventoried_as to be provided at the same time.
@spec resource_check(Changeset.t()) :: Changeset.t()
defp resource_check(cset) do
	# credo:disable-for-previous-line Credo.Check.Refactor.CyclomaticComplexity

	{data_res_con, chng_res_con} =
		case Changeset.fetch_field(cset, :resource_conforms_to_id) do
			{:data, x} -> {x, nil}
			{:changes, x} -> {nil, x}
		end
	{data_res_inv, chng_res_inv} =
		case Changeset.fetch_field(cset, :resource_inventoried_as_id) do
			{:data, x} -> {x, nil}
			{:changes, x} -> {nil, x}
		end

	cond do
		data_res_con && chng_res_inv ->
			msg = "resource_inventoried_as is not allowed in this record"
			Changeset.add_error(cset, :resource_inventoried_as_id, msg)

		data_res_inv && chng_res_con ->
			msg = "resource_conforms_to is not allowed in this record"
			Changeset.add_error(cset, :resource_conforms_to_id, msg)

		chng_res_con && chng_res_inv ->
			msg = "resource_conforms_to and resource_inventoried_as are mutually exclusive"

			cset
			|> Changeset.add_error(:resource_conforms_to_id, msg)
			|> Changeset.add_error(:resource_inventoried_as_id, msg)

		true ->
			cset
	end
end
end
