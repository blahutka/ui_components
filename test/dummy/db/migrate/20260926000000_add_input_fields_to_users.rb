# One attribute per remaining `form.ui` helper in the form builder demo
class AddInputFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_table :users do |t|
      t.string :email
      t.string :website
      t.json :tags, default: []
      t.string :city
      t.integer :score
      t.boolean :featured, default: false, null: false
      t.string :alignment
      t.json :formats, default: []
    end
  end
end
