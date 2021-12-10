defmodule ZenflowsTest.Valflow.ResourceSpecification.Domain do
use ZenflowsTest.Case.Repo, async: true

alias Ecto.Changeset
alias Zenflows.Valflow.{
	ResourceSpecification,
	ResourceSpecification.Domain,
	Unit,
}

setup do
	%{
		params: %{
			name: Factory.uniq("name"),
			resource_classified_as: Factory.uniq_list("uri"),
			note: Factory.uniq("note"),
			image: Factory.uri(),
			default_unit_of_effort_id: Factory.insert!(:unit).id,
			default_unit_of_resource_id: Factory.insert!(:unit).id,
		},
		resource_specification: Factory.insert!(:resource_specification),
	}
end

test "by_id/1 returns a ResourceSpecification", %{resource_specification: res_spec} do
	assert %ResourceSpecification{} = Domain.by_id(res_spec.id)
end

describe "create/1" do
	test "creates a ResourceSpecification with valid params", %{params: params} do
		assert {:ok, %ResourceSpecification{} = res_spec} = Domain.create(params)

		assert res_spec.name == params.name
		assert res_spec.resource_classified_as == params.resource_classified_as
		assert res_spec.note == params.note
		assert res_spec.image == params.image
		assert res_spec.default_unit_of_resource_id == params.default_unit_of_resource_id
		assert res_spec.default_unit_of_effort_id == params.default_unit_of_effort_id
	end

	test "doesn't create a ResourceSpecification with invalid params" do
		assert {:error, %Changeset{}} = Domain.create(%{})
	end
end

describe "update/2" do
	test "updates a ResourceSpecification with valid params", %{params: params, resource_specification: old} do
		assert {:ok, %ResourceSpecification{} = new} = Domain.update(old.id, params)

		assert new.name == params.name
		assert new.resource_classified_as == params.resource_classified_as
		assert new.note == params.note
		assert new.image == params.image
		assert new.default_unit_of_resource_id == params.default_unit_of_resource_id
		assert new.default_unit_of_effort_id == params.default_unit_of_effort_id
	end

	test "doesn't update a ResourceSpecification", %{resource_specification: old} do
		assert {:ok, %ResourceSpecification{} = new} = Domain.update(old.id, %{})

		assert new.name == old.name
		assert new.resource_classified_as == old.resource_classified_as
		assert new.note == old.note
		assert new.image == nil # old.image
		assert new.default_unit_of_resource_id == old.default_unit_of_resource_id
		assert new.default_unit_of_effort_id == old.default_unit_of_effort_id
	end
end

test "delete/1 deletes a ResourceSpecification", %{resource_specification: %{id: id}} do
	assert {:ok, %ResourceSpecification{id: ^id}} = Domain.delete(id)
	assert Domain.by_id(id) == nil
end

describe "preload/2" do
	test "preloads :default_unit_of_resource", %{resource_specification: res_spec} do
		res_spec = Domain.preload(res_spec, :default_unit_of_resource)
		assert unit_res = %Unit{} = res_spec.default_unit_of_resource
		assert unit_res.id == res_spec.default_unit_of_resource_id
	end

	test "preloads :default_unit_of_effort", %{resource_specification: res_spec} do
		res_spec = Domain.preload(res_spec, :default_unit_of_effort)
		assert unit_eff = %Unit{} = res_spec.default_unit_of_effort
		assert unit_eff.id == res_spec.default_unit_of_effort_id
	end
end
end
