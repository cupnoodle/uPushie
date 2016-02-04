class CreateStudents < ActiveRecord::Migration
  def up
    create_table :students do |t|

      # may not compatible with dbms other than mysql
      t.column  :utar_id, "char(7)" , null: false

      # device token/registration_id
      t.string  :device_token,      null: true, limit: 64
      t.column  :registration_id, :mediumtext,  null: true

      # ios or android enum, 0 is ios, 1 is android
      t.integer :os, default: 0

      # last login datetime
      t.datetime :last_login

      t.timestamps null: false
    end

    add_index :students, :utar_id, unique: true
  end

  def down
    drop_table :students
  end

end
