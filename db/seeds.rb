# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ENV.fetch("SEED_USERS") { "" }.split(";").each do |s|
  m = s.match(/(?<username>.+):(?<password>.+)<(?<email>.+@.+)>/)
  username = m["username"]&.strip
  email = m["email"]&.strip
  password = m["password"]&.strip
  if username.present? && email.present?
    User.create_or_find_by(username: username, email: email, password: password)
  end
end

VocabularyFilter.find_or_initialize_by(name: "default").tap do |x|
  if x.new_record?
    x.word_list = []
    x.save!
  end
end
