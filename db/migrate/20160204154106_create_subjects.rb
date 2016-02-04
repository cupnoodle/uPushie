class CreateSubjects < ActiveRecord::Migration
  def up
    create_table :subjects do |t|
      #may not compatible with dbms other than mysql
      t.column  :code, "char(9)", null: false
      t.string  :name, :limit => 128, null: false
      t.string  :url, :limit => 128, null: false

      t.column  :cached_text, :mediumtext
      t.column  :latest_hash, "char(32)"


      t.timestamps null: false
    end

    add_index :subjects, :code, unique: true
  end

  def down
    drop_table :subjects
  end
end
