# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Seed a staff user for admin access
staff_email = ENV.fetch("STAFF_EMAIL", "staff@example.com")
staff_password = ENV.fetch("STAFF_PASSWORD", "password123")

staff_user = User.find_or_initialize_by(email: staff_email)
staff_user.assign_attributes(
  username: "staff",
  password: staff_password,
  password_confirmation: staff_password,
  staff: true,
  confirmed_at: Time.current,
  given_name: "Staff",
  surname: "User"
)
if staff_user.changed?
  staff_user.save!
  puts "Seeded staff user: #{staff_email}"
else
  puts "Staff user already exists: #{staff_email}"
end

# Seed genres
genres_data = [
  {name: "RPG", key: "rpg"},
  {name: "Browser", key: "browser"},
  {name: "Platform/Action", key: "platform_action"},
  {name: "Shoot em up", key: "shoot_em_up"},
  {name: "Puzzle", key: "puzzle"},
  {name: "Point and Click", key: "point_and_click"},
  {name: "Sport", key: "sport"},
  {name: "Fighting", key: "fighting"},
  {name: "Other", key: "other"}
]

puts "Seeding genres..."
genres_data.each do |genre_data|
  genre = Genre.find_or_initialize_by(key: genre_data[:key])
  genre.assign_attributes(name: genre_data[:name])

  if genre.changed?
    genre.save!
    puts "Created genre: #{genre.name} (#{genre.key})"
  else
    puts "Genre already exists: #{genre.name} (#{genre.key})"
  end
end

puts "Finished seeding genres. Total genres: #{Genre.count}"

# Seed development tools
tools_data = [
  "DragonRuby",
  "AppGameKit",
  "GDevelop",
  "Pocket Platformer",
  "Defold Engine",
  "Rpg Maker MZ",
  "GameMaker Studio 2",
  "GameMaker Studio 1",
  "TIC-80",
  "Phaser",
  "LÖVE",
  "PICO-8",
  "Construct 3",
  "Twine",
  "Smile Game Builder",
  "Stencyl",
  "Superpowers",
  "Godot",
  "Unreal Engine",
  "3D Adventure Studio",
  "Mugen",
  "3D Rad",
  "Ogre 3D",
  "Zelda Classic",
  "Verge 3",
  "Unity",
  "Super Mario Bors X",
  "Sphere",
  "Sim Rpg Maker 95",
  "Rpg Toolkit",
  "Rpg Maker MV",
  "Rpg Maker VX ACE",
  "Rpg Maker VX",
  "Rpg Maker XP",
  "Rpg Maker 95",
  "Rpg Maker 2003",
  "Rpg Maker 2000",
  "Renpy",
  "OHRRPGCE",
  "Multimedia Fusion 2",
  "Multimedia Fusion",
  "Ika",
  "IG Maker",
  "GameMaker",
  "Engine001",
  "Eclipse Origin",
  "Easy RPG",
  "Custom",
  "Construct classic",
  "Construct 2",
  "Adventure Game Studio",
  "Other",
  "Unknown"
]

puts "Seeding development tools..."
tools_data.each do |tool_name|
  tool = Tool.find_or_initialize_by(name: tool_name)

  if tool.changed?
    tool.save!
    puts "Created tool: #{tool.name}"
  else
    puts "Tool already exists: #{tool.name}"
  end
end

puts "Finished seeding tools. Total tools: #{Tool.count}"

# Seed platforms
platforms_data = [
  "Windows",
  "Browser",
  "Linux",
  "Mac",
  "Android",
  "iPhone",
  "HTML5",
  "Flash",
  "Windows Phone"
]

puts "Seeding platforms..."
platforms_data.each do |platform_name|
  platform = Platform.find_or_initialize_by(name: platform_name)

  if platform.changed?
    platform.save!
    puts "Created platform: #{platform.name}"
  else
    puts "Platform already exists: #{platform.name}"
  end
end

puts "Finished seeding platforms. Total platforms: #{Platform.count}"
