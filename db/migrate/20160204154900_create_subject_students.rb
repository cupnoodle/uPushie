class CreateSubjectStudents < ActiveRecord::Migration
  def up
    create_table :subject_students do |t|
      #might not work in dbms other than mysql
      t.column  :student_utar_id, "char(7)" , null: false
      t.column  :subject_code, "char(9)", null: false

      t.timestamps null: false
    end

    add_index :subject_students, :student_utar_id
    add_index :subject_students, :subject_code
    add_index :subject_students, [:student_utar_id, :subject_code], unique: true
  end

  def down
    drop_table :subject_students
  end
end
