defmodule Zenflows.Valflow.RoleBehavior.Domain do
@moduledoc "Domain logic of RoleBehaviors."

alias Ecto.Multi
alias Zenflows.Ecto.Repo
alias Zenflows.Valflow.RoleBehavior

@typep repo() :: Ecto.Repo.t()
@typep chset() :: Ecto.Changeset.t()
@typep changes() :: Ecto.Multi.changes()
@typep id() :: Zenflows.Ecto.Schema.id()
@typep params() :: Zenflows.Ecto.Schema.params()

@spec by_id(repo(), id()) :: RoleBehavior.t() | nil
def by_id(repo \\ Repo, id) do
	repo.get(RoleBehavior, id)
end

@spec create(params()) :: {:ok, RoleBehavior.t()} | {:error, chset()}
def create(params) do
	Multi.new()
	|> Multi.insert(:role_beh, RoleBehavior.chset(params))
	|> Repo.transaction()
	|> case do
		{:ok, %{role_beh: rb}} -> {:ok, rb}
		{:error, _, cset, _} -> {:error, cset}
	end
end

@spec update(id(), params()) :: {:ok, RoleBehavior.t()} | {:error, chset()}
def update(id, params) do
	Multi.new()
	|> Multi.run(:get, multi_get(id))
	|> Multi.update(:update, &RoleBehavior.chset(&1.get, params))
	|> Repo.transaction()
	|> case do
		{:ok, %{update: rb}} -> {:ok, rb}
		{:error, _, msg_or_cset, _} -> {:error, msg_or_cset}
	end
end

@spec delete(id()) :: {:ok, RoleBehavior.t()} | {:error, chset()}
def delete(id) do
	Multi.new()
	|> Multi.run(:get, multi_get(id))
	|> Multi.delete(:delete, &(&1.get))
	|> Repo.transaction()
	|> case do
		{:ok, %{delete: rb}} -> {:ok, rb}
		{:error, _, msg_or_cset, _} -> {:error, msg_or_cset}
	end
end

# Returns a RoleBehavior in ok-err tuple from given ID.  Used inside
# Ecto.Multi.run/5 to get a record in transaction.
@spec multi_get(id()) :: (repo(), changes() -> {:ok, RoleBehavior.t()} | {:error, String.t()})
defp multi_get(id) do
	fn repo, _ ->
		case by_id(repo, id) do
			nil -> {:error, "not found"}
			rb -> {:ok, rb}
		end
	end
end
end
