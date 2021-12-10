defmodule Zenflows.Valflow.Person.Type do
@moduledoc "GraphQL types of Persons."

use Absinthe.Schema.Notation

alias Zenflows.Valflow.Person.Resolv

@name "The name that this agent will be referred to by."
@image """
The URI to an image relevant to the agent, such as a logo, avatar,
photo, etc.
"""
@note "A textual description or comment."
@primary_location """
The main place an agent is located, often an address where activities
occur and mail can be sent.	 This is usually a mappable geographic
location.  It also could be a website address, as in the case of agents
who have no physical location.
"""
@user "Username of the agent.  Implies uniqueness."
@email "Email address of the agent.  Implies uniqueness."
@pass """
Plain passphrase of the person.  It will be hashed then stored.
The orginal, plaintext, will be discarded.
"""

@desc "A natural person."
object :person do
	interface :agent

	field :id, non_null(:id)

	@desc @name
	field :name, non_null(:string)

	@desc @image
	field :image, :uri

	@desc @note
	field :note, :string

	@desc @primary_location
	field :primary_location, :spatial_thing,
		resolve: &Resolv.primary_location/3

	@desc @user
	field :user, non_null(:string)

	@desc @email
	field :email, non_null(:string)
end

object :person_response do
	field :agent, non_null(:person)
end

input_object :person_create_params do
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

	@desc @user
	field :user, non_null(:string)

	@desc @email
	field :email, non_null(:string)

	@desc @pass
	field :pass_plain, non_null(:string), name: "pass"
end

input_object :person_update_params do
	field :id, non_null(:id)

	@desc @name
	field :name, :string

	@desc @image
	field :image, :uri

	@desc @note
	field :note, :string

	@desc "(`SpatialThing`) " <> @primary_location
	field :primary_location_id, :id, name: "primary_location"

	@desc @user
	field :user, :string

	@desc @pass
	field :pass_plain, :string, name: "pass"
end

object :query_person do
	@desc "Find a person by their ID."
	field :person, :person do
		arg :id, non_null(:id)
		resolve &Resolv.person/2
	end

	#"Loads all people who have publicly registered with this collaboration space."
	#people(start: ID, limit: Int): [Person!]
end

object :mutation_person do
	@desc "Registers a new (human) person with the collaboration space."
	field :create_person, :person_response do
		arg :person, non_null(:person_create_params)
		resolve &Resolv.create_person/2
	end

	@desc "Update profile details."
	field :update_person, :person_response do
		arg :person, non_null(:person_update_params)
		resolve &Resolv.update_person/2
	end

	@desc """
	Erase record of a person and thus remove them from the
	collaboration space.
	"""
	field :delete_person, :boolean do
		arg :id, non_null(:id)
		resolve &Resolv.delete_person/2
	end
end
end
