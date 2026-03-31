class CreateNota < ActiveRecord::Migration[8.0]
  def change
    create_table :nota do |t|
      t.string :titulo
      t.text :descricao
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
