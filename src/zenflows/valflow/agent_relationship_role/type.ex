defmodule Zenflows.Valflow.AgentRelationshipRole.Type do
@moduledoc "GraphQL types of AgentRelationshipRoles."

use Absinthe.Schema.Notation

alias Zenflows.Valflow.AgentRelationshipRole.Resolv

@role_behavior """
The general shape or behavior grouping of an agent relationship role.
"""
@role_label """
The human readable name of the role, from the subject to the object.
"""
@inverse_role_label """
The human readable name of the role, from the object to the subject.
"""
@note "A textual description or comment."

object :agent_relationship_role do
	field :id, non_null(:id)

	@desc @role_behavior
	field :role_behavior, :role_behavior,
		resolve: &Resolv.role_behavior/3

	@desc @role_label
	field :role_label, non_null(:string)

	@desc @inverse_role_label
	field :inverse_role_label, :string

	@desc @note
	field :note, :string
end

object :agent_relationship_role_response do
	field :agent_relationship_role, non_null(:agent_relationship_role)
end

input_object :agent_relationship_role_create_params do
	# TODO: When
	# https://github.com/absinthe-graphql/absinthe/issues/1126 results,
	# apply the correct changes if any.
	@desc "(`RoleBhavior`) " <> @role_behavior
	field :role_behavior_id, :id, name: "role_behavior"

	@desc @role_label
	field :role_label, non_null(:string)

	@desc @inverse_role_label
	field :inverse_role_label, :string

	@desc @note
	field :note, :string
end

input_object :agent_relationship_role_update_params do
	field :id, non_null(:id)

	@desc "(`RoleBhavior`) " <> @role_behavior
	field :role_behavior_id, :id, name: "role_behavior"

	@desc @role_label
	field :role_label, :string

	@desc @inverse_role_label
	field :inverse_role_label, :string

	@desc @note
	field :note, :string
end

object :query_agent_relationship_role do
	@desc "Retrieve details of an agent relationship role by its ID."
	field :agent_relationship_role, :agent_relationship_role do
		arg :id, non_null(:id)
		resolve &Resolv.agent_relationship_role/2
	end

	# @desc """
	# Retrieve possible kinds of associations that agents may have
	# with one another in this collaboration space.
	# """
	# agentRelationshipRoles(start: ID, limit: Int): [AgentRelationshipRole!]
end

object :mutation_agent_relationship_role do
	field :create_agent_relationship_role, :agent_relationship_role_response do
		arg :agent_relationship_role, non_null(:agent_relationship_role_create_params)
		resolve &Resolv.create_agent_relationship_role/2
	end

	field :update_agent_relationship_role, :agent_relationship_role_response do
		arg :agent_relationship_role, non_null(:agent_relationship_role_update_params)
		resolve &Resolv.update_agent_relationship_role/2
	end

	field :delete_agent_relationship_role, :boolean do
		arg :id, non_null(:id)
		resolve &Resolv.delete_agent_relationship_role/2
	end
end
end
