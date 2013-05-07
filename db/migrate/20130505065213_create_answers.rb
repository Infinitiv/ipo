class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :question, index: true
      t.string :text
      t.boolean :right

      t.timestamps
    end
  end
end
