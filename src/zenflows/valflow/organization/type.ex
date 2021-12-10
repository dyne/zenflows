defmodule Zenflows.Valflow.Organization.Type do
@moduledoc "GraphQL types of Organizations."

use Absinthe.Schema.Notation

alias Zenflows.Valflow.Organization.Resolv

@name "The name that this agent will be referred to by."
@image """
The URI to an image relevant to the agent, such as a logo, avatar,
photo, etc.
"""
@primary_location """
The main place an agent is located, often an address where activities
occur and mail can be sent.	 This is usually a mappable geographic
location.  It also could be a website address, as in the case of agents
who have no physical location.
"""
@note "A textual description or comment."
@classified_as """
References one or more concepts in a common taxonomy or other
classification scheme for purposes of categorization or grouping.
"""

@desc "A formal or informal group, or legal organization."
object :organization do
	interface :agent

	field :id, non_null(:id)

	@desc @name
	field :name, non_null(:string)

	@desc @image
	field :image, :uri

	@desc @primary_location
	field :primary_location, :spatial_thing,
		resolve: &Resolv.primary_location/3

	@desc @note
	field :note, :string

	@desc @classified_as
	field :classified_as, list_of(non_null(:string))
end

object :organization_response do
	field :agent, non_null(:organization)
end

input_object :organization_create_params do
	@desc @name
	field :name, non_null(:string)

	@desc @image
	field :image, :uri

	@desc @note
	field :note, :string

	# TODO: When
	# https://github.com/absinthe-graphql/absinthe/issues/1126 results,
	# apply the correct changes if any.
	@desc "(`SpatialThing`) " <> @primary_location
	field :primary_location_id, :id, name: "primary_location"

	@desc @classified_as
	field :classified_as, list_of(non_null(:string))
end

input_object :organization_update_params do
	field :id, non_null(:id)

	@desc @name
	field :name, :string

	@desc @image
	field :image, :uri

	@desc @note
	field :note, :string

	@desc "(`SpatialThing`) " <> @primary_location
	field :primary_location_id, :id, name: "primary_location"

	@desc @classified_as
	field :classified_as, list_of(non_null(:string))
end

object :query_organization do
	@desc "Find an organization (group) agent by its ID."
	field :organization, :organization do
		arg :id, non_null(:id)
		resolve &Resolv.organization/2
	end

	#"Loads all organizations publicly registered within this collaboration space"
	#organizations(start: ID, limit: Int): [Organization!]
end

object :mutation_organization do
	@desc """
	Registers a new organization (group agent) with the
	collaboration space.
	"""
	field :create_organization, :organization_response do
		arg :organization, non_null(:organization_create_params)
		resolve &Resolv.create_organization/2
	end

	@desc "Update organization profile details."
	field :update_organization, :organization_response do
		arg :organization, non_null(:organization_update_params)
		resolve &Resolv.update_organization/2
	end

	@desc """
	Erase record of an organization and thus remove it from
	the collaboration space.
	"""
	field :delete_organization, :boolean do
		arg :id, non_null(:id)
		resolve &Resolv.delete_organization/2
	end
end
end
