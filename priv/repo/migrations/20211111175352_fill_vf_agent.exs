defmodule Zenflows.Ecto.Repo.Migrations.Fill_vf_agent do
use Ecto.Migration

@mutex_check """
(
	type = 'per'
	AND "user" IS NOT NULL
	AND email IS NOT NULL
	AND pass IS NOT NULL
	AND classified_as IS NULL
)
OR
(
	type = 'org'
	AND "user" IS NULL
	AND email IS NULL
	AND pass IS NULL
)
"""

def change() do
	alter table("vf_agent") do
		add :type, :vf_agent_enum, null: false

		# common
		add :name, :text, null: false
		# add :image
		add :note, :text
		add :primary_location_id, references("vf_spatial_thing")

		# person
		add :user, :text
		add :email, :citext
		add :pass, :binary

		# organization
		add :classified_as, {:array, :text}
	end

	create index("vf_agent", :type)
	create unique_index("vf_agent", :user, when: "user IS NOT NULL")
	create unique_index("vf_agent", :email, when: "email IS NOT NULL")
	create constraint("vf_agent", :mutex, check: @mutex_check)
end
end
