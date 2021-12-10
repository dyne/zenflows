defmodule Zenflows.Ecto.Repo.Migrations.Fill_vf_agent_relationship_role do
use Ecto.Migration

def change() do
	alter table("vf_agent_relationship_role") do
		add :role_behavior_id, references("vf_role_behavior")
		add :role_label, :text, null: false
		add :inverse_role_label, :text
		add :note, :text
	end
end
end
