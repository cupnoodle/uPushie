class SubjectStudent < ActiveRecord::Base

  belongs_to :student, :foreign_key => 'student_utar_id', :primary_key => 'utar_id'
  belongs_to :subject, :foreign_key => 'subject_code', :primary_key => 'code'

  # Add the enum set values to campus enum, 0 is perak, 1 is foundation perak, 2 is pj, 3 is foundation pj, 4 is kl, 5 is sungailong, 6 is sungailong-ipsr, 7 is fmhs
  enum campus: [:pk, :cfspk, :pj, :cfspj, :kl, :sl, :ipsrsl, :fmhs]
end
