class SubjectStudent < ActiveRecord::Base

  belongs_to :student, :foreign_key => 'student_utar_id', :primary_key => 'utar_id'
  belongs_to :subject, :foreign_key => 'subject_code', :primary_key => 'code'

end
