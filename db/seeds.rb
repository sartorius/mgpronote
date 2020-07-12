
=begin
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
=end
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


=begin
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

=end

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
=begin
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
=end
