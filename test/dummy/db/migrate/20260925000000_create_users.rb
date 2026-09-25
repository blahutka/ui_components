# The form builder demo's records (app/models/user.rb, address.rb, phone.rb)
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.text :bio
      t.json :locations, default: []
      t.string :plan
      t.json :interests, default: []
      t.string :language
      t.json :skills, default: []
      t.integer :experience, default: 0
      t.boolean :newsletter, default: false, null: false
      t.string :pin
      t.timestamps
    end

    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: false
      t.string :city
      t.string :country
      t.timestamps
    end

    create_table :phones do |t|
      t.references :user, null: false, foreign_key: false
      t.string :number
      t.string :kind
      t.timestamps
    end
  end
end
