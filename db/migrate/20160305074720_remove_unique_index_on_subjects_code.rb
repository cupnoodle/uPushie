class RemoveUniqueIndexOnSubjectsCode < ActiveRecord::Migration
  def up
  	remove_index :subjects, column: :code if index_exists?(:subjects, :code, unique: true)
  	remove_index :subject_students, column: [:student_utar_id, :subject_code] if index_exists?(:subject_students, [:student_utar_id, :subject_code], unique: true)

  	add_index :subjects, [:code, :campus], unique: true
  	add_index :subject_students, [:student_utar_id, :subject_code, :campus], unique: true, name: 'unique_utar_id_subject_code_campus'

  	add_index :subject_students, :campus
  end

  def down
  	remove_index :subjects, column: [:code, :campus] if index_exists?(:subjects, [:code, :campus], unique: true)
  	remove_index :subject_students, name: 'unique_utar_id_subject_code_campus' if index_exists?(:subject_students, [:student_utar_id, :subject_code, :campus], name: 'unique_utar_id_subject_code_campus')

  	remove_index :subject_students, column: :campus
  	
  	add_index :subjects, :code, unique: true
  	add_index :subject_students, [:student_utar_id, :subject_code], unique: true
  end
end
