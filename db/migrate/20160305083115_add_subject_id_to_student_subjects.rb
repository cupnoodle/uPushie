class AddSubjectIdToStudentSubjects < ActiveRecord::Migration
  def change
  	add_reference :subject_students, :subject, index: true
  	add_reference :subject_students, :student, index: true
  	add_foreign_key :subject_students, :subjects
  	add_foreign_key :subject_students, :students
  end
end
