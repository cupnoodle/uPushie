class AddPasswordHashToStudent < ActiveRecord::Migration
  def up
    #md5
    add_column :students, :utar_password_hash, :string, :limit => 32 
  end

  def down
    remove_column :students, :utar_password_hash
  end

end
