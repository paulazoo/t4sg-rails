class Initial < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string(:first_name)
      t.string(:last_name)
      t.string(:email)
      t.string(:bio)
      t.string(:password_digest)
      t.string(:refresh_token_id)

      t.timestamps
    end

  end
end
