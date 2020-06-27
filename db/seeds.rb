# Create a main sample user.
User.create!(name:  "Ratinahirana",
             firstname: "Herinirina",
             email: "ratinahirana@gmail.com",
             password:              "madagascar12",
             password_confirmation: "madagascar12",
             phone: "0320102033",
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "Rakotoarinia",
            firstname: "Toky",
            email: "rakotoarinia.toky@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     true,
            activated: true,
            activated_at: Time.zone.now)

User.create!(name:  "Rakotomalala",
            firstname: "Mamy",
            email: "rakoto.mamy@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0612345678",
            admin:     false,
            incharge:     true,
            activated: true,
            activated_at: Time.zone.now)

User.create!(name:  "Razanamalaza",
            firstname: "Hery",
            email: "raza.hery@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0612345690",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)

# Generate a bunch of additional users.
2.times do |n|
  name  = Faker::Name.name
  email = "fake-#{n+1}@mgsuivi.com"
  password = "password"
  User.create!(name:  name,
              email: email,
              password:              password,
              password_confirmation: password,
              activated: true,
              activated_at: Time.zone.now)
end
