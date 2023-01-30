# Zenflows is designed to implement the Valueflows vocabulary,
# written and maintained by srfsh <info@dyne.org>.
# Copyright (C) 2021-2023 Dyne.org foundation <foundation@dyne.org>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

defmodule Zenflows.DB.Repo do
@moduledoc "The Ecto Repository of Zenflows."

use Ecto.Repo,
	otp_app: :zenflows,
	adapter: Ecto.Adapters.Postgres

@spec multi((-> {:ok | :error, term()})
		| (Ecto.Repo.t() -> {:ok | :error, term()}))
	:: {:ok | :error, term()}
def multi(fun) when is_function(fun, 0) do
	transaction(fn ->
		case fun.() do
			{:ok, v} -> v
			{:error, v} -> rollback(v)
		end
	end)
end
def multi(fun) when is_function(fun, 1) do
	transaction(fn repo ->
		case fun.(repo) do
			{:ok, v} -> v
			{:error, v} -> rollback(v)
		end
	end)
end
end
