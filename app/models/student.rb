class Student < ActiveRecord::Base

  has_many :subject_students, class_name:'SubjectStudent',  :foreign_key => 'student_utar_id', :primary_key => 'utar_id', :dependent => :destroy
  has_many :subjects, :through => :subject_students

  # 7-8 digit, in case utar increase 1 digit to id
  # validates utar ID
  UTAR_ID_REGEX = /\d{7,8}/
  validates :utar_id, :presence => true, :length => { :minimum=> 7, :maximum => 8 }, :format => UTAR_ID_REGEX, :uniqueness => true
  validates :utar_password_hash, :presence => true

  # Add the enum set values to os, default is 0 (ios) as defined in the create_students.rb migration
  enum os: [:ios, :android]

  # Add the enum set values to campus enum, 0 is perak, 1 is foundation perak, 2 is pj, 3 is foundation pj, 4 is kl, 5 is sungailong, 6 is sungailong-ipsr, 7 is fmhs
  enum campus: [:pk, :cfspk, :pj, :cfspj, :kl, :sl, :ipsrsl, :fmhs]

  # validate presence of device_token if os is ios
  # validates_presence_of :device_token, :if => lambda { self.ios? }

  # validate presence of registration_id if os is android
  # validates_presence_of :registration_id, :if => lambda { self.android? }

  # Sorted scope for easier ordering
  scope :sorted, lambda{ order("utar_id ASC") }

end
