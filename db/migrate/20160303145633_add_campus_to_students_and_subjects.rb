class AddCampusToStudentsAndSubjects < ActiveRecord::Migration
  def up
  	# campus enum, 0 is perak, 1 is foundation perak, 2 is pj, 3 is foundation pj, 4 is kl, 5 is sungailong, 6 is sungailong-ipsr, 7 is fmhs
  	add_column :students, :campus, :integer, :default => 0 , :after => :utar_id
  	add_column :subject_students, :campus, :integer, :default => 0 , :after => :subject_code
  	add_column :subjects, :campus, :integer, :default => 0 , :after => :code
  end

  def down
  	remove_column :students, :campus
  	remove_column :subject_students, :campus
  	remove_column :subjects, :campus
  end

end
