# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# If the iOS app is not created in database yet then create
if !Rpush::Apns::App.find_by_name("ios_upush")
  ios_app = Rpush::Apns::App.new
  ios_app.name = "ios_upush"
  ios_app.certificate = File.read( File.join(Rails.root, 'cert', 'upush.pem') )
  ios_app.environment = "sandbox" # APNs environment.
  ios_app.password = "=w=/\\=w="
  ios_app.connections = 1
  ios_app.save!
end

# If the Android app is not created in database yet then create
if !Rpush::Gcm::App.find_by_name("android_upush")
  android_app = Rpush::Gcm::App.new
  android_app.name = "android_upush"
  android_app.auth_key = "AIzaSyCDcRmI0dcgNkaLhU0RGQrbwhe0PH3qHUk"
  android_app.connections = 1
  android_app.save!
end