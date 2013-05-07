class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.references :subject, index: true
      t.string :text

      t.timestamps
    end
  end
end
