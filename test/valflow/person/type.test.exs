defmodule ZenflowsTest.Valflow.Person.Type do
use ZenflowsTest.Case.Absin, async: true

setup do
	%{
		params: %{
			name: Factory.uniq("name"),
			# image
			note: Factory.uniq("note"),
			primary_location_id: Factory.insert!(:spatial_thing).id,
			user: Factory.uniq("user"),
			email: Factory.uniq("email"),
			pass_plain: Factory.pass_plain(),
		},
		per: Factory.insert!(:person),
	}
end

describe "Query" do
	test "person()", %{per: per} do
		assert %{data: %{"person" => data}} =
			query!("""
				person(id: "#{per.id}") {
					id
					name
					note
					primaryLocation { id }
					user
					email
				}
			""")

		assert data["id"] == per.id
		assert data["name"] == per.name
		assert data["note"] == per.note
		assert data["primaryLocation"]["id"] == per.primary_location_id

		assert data["user"] == per.user
		assert data["email"] == per.email
	end
end

describe "Mutation" do
	test "createPerson()", %{params: params} do
		assert %{data: %{"createPerson" => %{"agent" => data}}} =
			mutation!("""
				createPerson(person: {
					name: "#{params.name}"
					note: "#{params.note}"
					primaryLocation: "#{params.primary_location_id}"
					user: "#{params.user}"
					email: "#{params.email}"
					pass: "#{params.pass_plain}"
				}) {
					agent {
						id
						name
						note
						primaryLocation { id }
						user
						email
					}
				}
			""")

		assert {:ok, _} = Zenflows.Ecto.Id.cast(data["id"])
		assert data["name"] == params.name
		assert data["note"] == params.note
		assert data["primaryLocation"]["id"] == params.primary_location_id
		assert data["user"] == params.user
		assert data["email"] == params.email
	end

	test "updatePerson()", %{params: params, per: per} do
		assert %{data: %{"updatePerson" => %{"agent" => data}}} =
			mutation!("""
				updatePerson(person: {
					id: "#{per.id}"
					name: "#{params.name}"
					note: "#{params.note}"
					primaryLocation: "#{params.primary_location_id}"
					user: "#{params.user}"
					pass: "#{params.pass_plain}"
				}) {
					agent {
						id
						name
						note
						primaryLocation { id }
						user
						email
					}
				}
			""")

		assert data["id"] == per.id
		assert data["name"] == params.name
		assert data["note"] == params.note
		assert data["primaryLocation"]["id"] == params.primary_location_id
		assert data["user"] == params.user
		assert data["email"] == per.email
	end

	test "deletePerson()", %{per: per} do
		assert %{data: %{"deletePerson" => true}} =
			mutation!("""
				deletePerson(id: "#{per.id}")
			""")
	end
end
end
