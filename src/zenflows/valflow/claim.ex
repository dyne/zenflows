defmodule Zenflows.Valflow.Claim do
@moduledoc """
A claim for a future economic event(s) in reciprocity for an economic
event that already occurred.  For example, a claim for payment for goods
received.
"""
use Zenflows.Ecto.Schema

alias Zenflows.Valflow.{
	ActionEnum,
	Agent,
	EconomicEvent,
	Measure,
	ResourceSpecification,
	Validate,
}

@type t() :: %__MODULE__{
	action: ActionEnum.t(),
	provider: Agent.t(),
	receiver: Agent.t(),
	resource_classified_as: [String.t()] | nil,
	resource_conforms_to: ResourceSpecification.t() | nil,
	resource_quantity: Measure.t() | nil,
	effort_quantity: Measure.t() | nil,
	triggered_by: EconomicEvent.t(),
	due: DateTime.t() | nil,
	created: DateTime.t() | nil,
	finished: boolean(),
	note: String.t() | nil,
	agreed_in: String.t() | nil,
	# in_scope_of:
}

schema "vf_claim" do
	field :action, ActionEnum
	belongs_to :provider, Agent
	belongs_to :receiver, Agent
	field :resource_classified_as, {:array, :string}
	belongs_to :resource_conforms_to, ResourceSpecification
	belongs_to :resource_quantity, Measure
	belongs_to :effort_quantity, Measure
	belongs_to :triggered_by, EconomicEvent
	field :due, :utc_datetime_usec
	field :created, :utc_datetime_usec
	field :finished, :boolean
	field :note, :string
	field :agreed_in, :string
	# field :in_scope_of
end

@reqr ~w[action provider_id receiver_id]a
@cast @reqr ++ ~w[
	resource_classified_as resource_conforms_to_id
	resource_quantity_id effort_quantity_id
	triggered_by_id due created finished note agreed_in
]a # in_scope_of

@doc false
@spec chset(Schema.t(), params()) :: Changeset.t()
def chset(schema \\ %__MODULE__{}, params) do
	schema
	|> Changeset.cast(params, @cast)
	|> Changeset.validate_required(@reqr)
	|> Changeset.assoc_constraint(:provider)
	|> Changeset.assoc_constraint(:receiver)
	|> Changeset.assoc_constraint(:resource_conforms_to)
	|> Changeset.assoc_constraint(:resource_quantity)
	|> Changeset.assoc_constraint(:effort_quantity)
	|> Changeset.assoc_constraint(:triggered_by)
	|> Validate.note(:note)
	|> Validate.class(:resource_classified_as)
end
end
