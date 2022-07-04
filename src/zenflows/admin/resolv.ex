defmodule Zenflows.Admin.Resolv do
@moduledoc "Resolvers of Admin-related queries."

alias Zenflows.VF.Person

def create_user(params, _) do
	with :ok <- auth_admin(params),
			{:ok, per} <- Person.Domain.create(params) do
		{:ok, per}
	end
end

defp auth_admin(%{admin_key: key}) do
	with {:ok, key_given} <- Base.decode16(key, case: :lower),
			key_want = Application.fetch_env!(:zenflows, Zenflows.Admin)[:admin_key],
			true <- keys_match?(key_given, key_want) do
		:ok
	else _ ->
		{:error, "you are not authorized"}
	end
end

# TODO: replace with `:crypto.hash_equals/2` when we require OTP 25.
defp keys_match?(left, right) do
	byte_size(left) == byte_size(right) and keys_match?(left, right, 0)
end

defp keys_match?(<<x, left::binary>>, <<y, right::binary>>, acc) do
	xorred = Bitwise.bxor(x, y)
	keys_match?(left, right, Bitwise.bor(acc, xorred))
end

defp keys_match?(<<>>, <<>>, acc) do
	acc === 0
end
end
