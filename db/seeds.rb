# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Seed a staff user for admin access
staff_email = ENV.fetch('STAFF_EMAIL', 'staff@example.com')
staff_password = ENV.fetch('STAFF_PASSWORD', 'password123')

staff_user = User.find_or_initialize_by(email: staff_email)
staff_user.assign_attributes(
  password: staff_password,
  password_confirmation: staff_password,
  staff: true,
  confirmed_at: Time.current,
  given_name: 'Staff',
  surname: 'User'
)
if staff_user.changed?
  staff_user.save!
  puts "Seeded staff user: #{staff_email}"
else
  puts "Staff user already exists: #{staff_email}"
end
