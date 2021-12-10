defmodule ZenflowsTest.Valflow.AgentRelationshipRole.Type do
use ZenflowsTest.Case.Absin, async: true

setup do
	%{
		params: %{
			role_behavior_id: Factory.insert!(:role_behavior).id,
			role_label: Factory.uniq("role label"),
			inverse_role_label: Factory.uniq("inverse role label"),
			note: Factory.uniq("note"),
		},
		agent_relationship_role: Factory.insert!(:agent_relationship_role),
	}
end

describe "Query" do
	test "agentRelationshipRole()", %{agent_relationship_role: rel_role} do
		assert %{data: %{"agentRelationshipRole" => data}} =
			query!("""
				agentRelationshipRole(id: "#{rel_role.id}") {
					id
					roleBehavior { id }
					roleLabel
					inverseRoleLabel
					note
				}
			""")

		assert data["id"] == rel_role.id
		assert data["roleBehavior"]["id"] == rel_role.role_behavior_id
		assert data["roleLabel"] == rel_role.role_label
		assert data["inverseRoleLabel"] == rel_role.inverse_role_label
		assert data["note"] == rel_role.note
	end
end

describe "Mutation" do
	test "createAgentRelationshipRole()", %{params: params} do
		assert %{data: %{"createAgentRelationshipRole" => %{"agentRelationshipRole" => data}}} =
			mutation!("""
				createAgentRelationshipRole(agentRelationshipRole: {
					roleBehavior: "#{params.role_behavior_id}"
					roleLabel: "#{params.role_label}"
					inverseRoleLabel: "#{params.inverse_role_label}"
					note: "#{params.note}"
				}) {
					agentRelationshipRole {
						id
						roleBehavior { id }
						roleLabel
						inverseRoleLabel
						note
					}
				}
			""")

		assert {:ok, _} = Zenflows.Ecto.Id.cast(data["id"])
		assert data["roleBehavior"]["id"] == params.role_behavior_id
		assert data["roleLabel"] == params.role_label
		assert data["inverseRoleLabel"] == params.inverse_role_label
		assert data["note"] == params.note
	end

	test "updateAgentRelationshipRole()", %{params: params, agent_relationship_role: rel_role} do
		assert %{data: %{"updateAgentRelationshipRole" => %{"agentRelationshipRole" => data}}} =
			mutation!("""
				updateAgentRelationshipRole(agentRelationshipRole: {
					id: "#{rel_role.id}"
					roleBehavior: "#{params.role_behavior_id}"
					roleLabel: "#{params.role_label}"
					inverseRoleLabel: "#{params.inverse_role_label}"
					note: "#{params.note}"
				}) {
					agentRelationshipRole {
						id
						roleBehavior { id }
						roleLabel
						inverseRoleLabel
						note
					}
				}
			""")

		assert data["id"] == rel_role.id
		assert data["roleBehavior"]["id"] == params.role_behavior_id
		assert data["roleLabel"] == params.role_label
		assert data["inverseRoleLabel"] == params.inverse_role_label
		assert data["note"] == params.note
	end

	test "deleteAgentRelationshipRole()", %{agent_relationship_role: %{id: id}} do
		assert %{data: %{"deleteAgentRelationshipRole" => true}} =
			mutation!("""
				deleteAgentRelationshipRole(id: "#{id}")
			""")
	end
end
end
