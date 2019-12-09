# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ENV.fetch("SEED_USERS") { "" }.split(";").each do |s|
  m = s.match(/(?<username>.+)<(?<email>.+@.+)>|(?<email>(?<username>.+)@.+)/)
  username = m["username"]&.strip
  email = m["email"]&.strip
  if username.present? && email.present?
    User.create_or_find_by(username: username, email: email)
  end
end
