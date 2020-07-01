

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
# Client
User.create!(name:  "Rakotoarinia",
            firstname: "Toky",
            email: "toky.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)
# Revendeur
User.create!(name:  "Hexagone",
            firstname: "Njara",
            email: "njara.h@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320182045",
            partner:   1,
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)
# Patron
User.create!(name:  "Rakotomalala",
            firstname: "Mamy",
            email: "mamy.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0612345678",
            admin:     false,
            partner:   2,
            incharge:     true,
            activated: true,
            activated_at: Time.zone.now)
# Livreur Receptionnaur
User.create!(name:  "Razanamalaza",
            firstname: "Rado",
            email: "rado.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0612345690",
            admin:     false,
            partner:   2,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)



###########################################################################
# Bunch of Clients
# Client
User.create!(name:  "De la Cannelle",
            firstname: "Tsiky",
            email: "tsiky.d@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)

# Client
User.create!(name:  "Razafy",
            firstname: "Hanitra",
            email: "hanitra.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)

# Client
User.create!(name:  "Rakoto",
            firstname: "Maeva",
            email: "maeva.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)

# Client
User.create!(name:  "Ramilison",
            firstname: "Mila",
            email: "mila.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)
