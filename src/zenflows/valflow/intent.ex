defmodule Zenflows.Valflow.Intent do
@moduledoc """
A planned economic flow which has not been committed to, which can lead
to economic events (sometimes through commitments).
"""
use Zenflows.Ecto.Schema

alias Zenflows.Valflow.{
	ActionEnum,
	Agent,
	EconomicResource,
	Measure,
	Process,
	ResourceSpecification,
	SpatialThing,
	Validate,
}

@type t() :: %__MODULE__{
	name: String.t() | nil,
	action: ActionEnum.t(),
	provider: Agent.t() | nil,
	receiver: Agent.t() | nil,
	input_of: Process.t() | nil,
	output_of: Process.t() | nil,
	resource_classified_as: [String.t()] | nil,
	resource_conforms_to: ResourceSpecification.t() | nil,
	resource_inventoried_as: EconomicResource.t() | nil,
	resource_quantity: Measure.t() | nil,
	effort_quantity: Measure.t() | nil,
	available_quantity: Measure.t() | nil,
	at_location: SpatialThing.t() | nil,
	has_beginning: DateTime.t() | nil,
	has_end: DateTime.t() | nil,
	has_point_in_time: DateTime.t() | nil,
	due: DateTime.t() | nil,
	finished: boolean(),
	image: String.t() | nil,
	note: String.t() | nil,
	# in_scope_of:
	agreed_in: String.t() | nil,
}

schema "vf_intent" do
	field :name
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
	belongs_to :available_quantity, Measure
	belongs_to :at_location, SpatialThing
	field :has_beginning, :utc_datetime_usec
	field :has_end, :utc_datetime_usec
	field :has_point_in_time, :utc_datetime_usec
	field :due, :utc_datetime_usec
	field :finished, :boolean, default: false
	field :image, :string, virtual: true
	field :note, :string
	# field :in_scope_of
	field :agreed_in, :string
end

@reqr [:action]
@cast @reqr ++ ~w[
	name provider_id receiver_id input_of_id output_of_id
	resource_classified_as resource_conforms_to_id resource_inventoried_as_id
	resource_quantity_id effort_quantity_id available_quantity_id
	at_location_id has_beginning has_end has_point_in_time due
	finished note image agreed_in
]a # in_scope_of_id

@doc false
@spec chset(Schema.t(), params()) :: Changeset.t()
def chset(schema \\ %__MODULE__{}, params) do
	schema
	|> Changeset.cast(params, @cast)
	|> Changeset.validate_required(@reqr)
	|> mutex_check()
	|> Validate.name(:name)
	|> Validate.note(:note)
	|> Validate.uri(:image)
	|> Validate.class(:resource_classified_as)
	|> Changeset.assoc_constraint(:provider)
	|> Changeset.assoc_constraint(:receiver)
	|> Changeset.assoc_constraint(:input_of)
	|> Changeset.assoc_constraint(:output_of)
	|> Changeset.assoc_constraint(:resource_conforms_to)
	|> Changeset.assoc_constraint(:resource_inventoried_as)
	|> Changeset.assoc_constraint(:resource_quantity)
	|> Changeset.assoc_constraint(:effort_quantity)
	|> Changeset.assoc_constraint(:available_quantity)
	|> Changeset.assoc_constraint(:at_location)
end

# Validate that provider and receiver are mutually exclusive.
@spec mutex_check(Changeset.t()) :: Changeset.t()
defp mutex_check(cset) do
	# credo:disable-for-previous-line Credo.Check.Refactor.CyclomaticComplexity

	{data_prov, chng_prov, field_prov} =
		case Changeset.fetch_field(cset, :provider_id) do
			{:data, x} -> {x, nil, x}
			{:changes, x} -> {nil, x, x}
		end
	{data_recv, chng_recv, field_recv} =
		case Changeset.fetch_field(cset, :receiver_id) do
			{:data, x} -> {x, nil, x}
			{:changes, x} -> {nil, x, x}
		end

	cond do
		data_prov && chng_recv ->
			msg = "receiver is not allowed in this record"
			Changeset.add_error(cset, :receiver_id, msg)

		data_recv && chng_prov ->
			msg = "provider is not allowed in this record"
			Changeset.add_error(cset, :provider_id, msg)

		chng_prov && chng_recv ->
			msg = "receiver is mutually exclusive with provider"

			cset
			|> Changeset.add_error(:provider_id, msg)
			|> Changeset.add_error(:receiver_id, msg)

		field_prov || field_recv ->
			cset

		true ->
			msg = "either provider or receiver is required"

			cset
			|> Changeset.add_error(:provider_id, msg)
			|> Changeset.add_error(:receiver_id, msg)
	end
end
end
