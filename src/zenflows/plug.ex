defmodule Zenflows.Plug do
@moduledoc "Plug entrypoint."

use Plug.Router

plug :match
plug Plug.RequestId
plug Plug.Logger
plug Plug.Parsers,
	parsers: [:json, Absinthe.Plug.Parser],
	pass: ["*/*"],
	json_decoder: Jason
plug :dispatch

forward "/api",
	to: Absinthe.Plug,
	schema: Zenflows.Absin.Schema

forward "/play",
	to: Absinthe.Plug.GraphiQL,
	schema: Zenflows.Absin.Schema,
	interface: :playground

match _ do
	conn
	|> put_resp_content_type("text/html")
	|> send_resp(404, """
		<a href="/play">go to the playground</a><br/>
		<a href="/api">the api location</a>
	""")
end
end
