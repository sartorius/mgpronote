
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
User.create!(name:  "Mada Techno Mafy",
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
User.create!(name:  "Rabemanara",
            firstname: "Fanny",
            email: "fanny.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0612345678",
            admin:     false,
            partner:   3,
            incharge:  true,
            activated: true,
            activated_at: Time.zone.now)



# Patron
User.create!(name:  "Rakotomalala",
            firstname: "Mafy",
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

# Livreur Receptionnaur
User.create!(name:  "Rakotobe",
            firstname: "Faly",
            email: "faly.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0322345690",
            admin:     false,
            partner:   2,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)


# Livreur Trans 2
User.create!(name:  "Rakomino",
            firstname: "Maurice",
            email: "maurice.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0322345690",
            admin:     false,
            partner:   4,
            incharge:  true,
            activated: true,
            activated_at: Time.zone.now)

User.create!(name:  "Rakomandroso",
            firstname: "Sylvie",
            email: "sylvie.r@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0322345690",
            admin:     false,
            partner:   4,
            incharge:  false,
            activated: true,
            activated_at: Time.zone.now)

###########################################################################
# Bunch of Clients
# Client
User.create!(name:  "Delamare",
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
            firstname: "Mavo",
            email: "mgsuivi@protonmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)

# Client
User.create!(name:  "Rafaly",
            firstname: "Thierry",
            email: "mgsuivi@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)

# Client
User.create!(name:  "Etsesamis",
            firstname: "Tapoty",
            email: "tapotyetsesamis@gmail.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0320102045",
            admin:     false,
            incharge:     false,
            activated: true,
            activated_at: Time.zone.now)
