class Subject < ActiveRecord::Base

  has_many :subject_students, class_name:'SubjectStudent', :foreign_key => 'subject_code', :primary_key => 'code', :dependent => :destroy
  has_many :students, :through => :subject_students

  # eg: UCCD1024 , three/four alphabet four/five digit
  # eg: MPW3255
  SUBJECT_CODE_REGEX = /[A-Z]{3,4}\d{4,5}/

  validates :code, :presence => true, :length => { :minimum=> 6, :maximum => 9 }, :format => SUBJECT_CODE_REGEX, :uniqueness => true
  validates :name, :presence => true, :length => { :minimum=> 1, :maximum => 128 }
  validates :url, :presence => true, :length => { :minimum=> 1, :maximum => 128 }

  scope :sorted_by_code, lambda{ order("code ASC") }
  scope :sorted_by_name, lambda{ order("name ASC") }
  scope :latest, lambda{ order("updated_at DESC") }
  
  # Add the enum set values to campus enum, 0 is perak, 1 is foundation perak, 2 is pj, 3 is foundation pj, 4 is kl, 5 is sungailong, 6 is sungailong-ipsr, 7 is fmhs
  enum campus: [:pk, :cfspk, :pj, :cfspj, :kl, :sl, :ipsrsl, :fmhs]
end
