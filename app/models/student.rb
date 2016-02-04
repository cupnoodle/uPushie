class Student < ActiveRecord::Base

  has_many :subject_students, class_name:'SubjectStudent',  :foreign_key => 'student_utar_id', :primary_key => 'utar_id', :dependent => :destroy
  has_many :subjects, :through => :subject_students

  # 7-8 digit, in case utar increase 1 digit to id
  # validates utar ID
  UTAR_ID_REGEX = /\d{7,8}/
  validates :utar_id, :presence => true, :length => { :minimum=> 7, :maximum => 8 }, :format => UTAR_ID_REGEX, :uniqueness => true

  # Add the enum set values to os, default is 0 (ios) as defined in the create_students.rb migration
  enum os: [:ios, :android]

  # Sorted scope for easier ordering
  scope :sorted, lambda{ order("utar_id ASC") }

end
