defmodule Zenflows.Valflow.AgentRelationshipRole.Domain do
@moduledoc "Domain logic of AgentRelationshipRoles."

alias Ecto.Multi
alias Zenflows.Ecto.Repo
alias Zenflows.Valflow.AgentRelationshipRole

@typep repo() :: Ecto.Repo.t()
@typep chset() :: Ecto.Changeset.t()
@typep changes() :: Ecto.Multi.changes()
@typep id() :: Zenflows.Ecto.Schema.id()
@typep params() :: Zenflows.Ecto.Schema.params()

@spec by_id(repo(), id()) :: AgentRelationshipRole.t() | nil
def by_id(repo \\ Repo, id) do
	repo.get(AgentRelationshipRole, id)
end

@spec create(params()) :: {:ok, AgentRelationshipRole.t()} | {:error, chset()}
def create(params) do
	Multi.new()
	|> Multi.insert(:rel_role, AgentRelationshipRole.chset(params))
	|> Repo.transaction()
	|> case do
		{:ok, %{rel_role: rr}} -> {:ok, rr}
		{:error, _, cset, _} -> {:error, cset}
	end
end

@spec update(id(), params()) :: {:ok, AgentRelationshipRole.t()} | {:error, chset()}
def update(id, params) do
	Multi.new()
	|> Multi.run(:get, multi_get(id))
	|> Multi.update(:update, &AgentRelationshipRole.chset(&1.get, params))
	|> Repo.transaction()
	|> case do
		{:ok, %{update: rr}} -> {:ok, rr}
		{:error, _, msg_or_cset, _} -> {:error, msg_or_cset}
	end
end

@spec delete(id()) :: {:ok, AgentRelationshipRole.t()} | {:error, chset()}
def delete(id) do
	Multi.new()
	|> Multi.run(:get, multi_get(id))
	|> Multi.delete(:delete, &(&1.get))
	|> Repo.transaction()
	|> case do
		{:ok, %{delete: rr}} -> {:ok, rr}
		{:error, _, msg_or_cset, _} -> {:error, msg_or_cset}
	end
end

@spec preload(AgentRelationshipRole.t(), :role_behavior) :: AgentRelationshipRole.t()
def preload(rel_role, :role_behavior) do
	Repo.preload(rel_role, :role_behavior)
end

# Returns an AgentRelationshipRole in ok-err tuple from given ID.
# Used inside Ecto.Multi.run/5 to get a record in transaction.
@spec multi_get(id()) :: (repo(), changes() -> {:ok, AgentRelationshipRole.t()} | {:error, String.t()})
defp multi_get(id) do
	fn repo, _ ->
		case by_id(repo, id) do
			nil -> {:error, "not found"}
			rr -> {:ok, rr}
		end
	end
end
end
