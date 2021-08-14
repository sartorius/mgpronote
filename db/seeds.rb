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


=end
###########################################################################
# Bunch of Clients

User.create!(name:  "Ratinahirana",
            firstname: "Herinirina",
            email: "heri.r@mg.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0322345690",
            admin:     true,
            partner:   5,
            incharge:  false,
            activated: true,
            activated_at: Time.zone.now)

User.create!(name:  "Rakotomalaza",
            firstname: "Rado",
            email: "rado.r@mg.com",
            password:              "madagascar12",
            password_confirmation: "madagascar12",
            phone: "0322345690",
            admin:     true,
            partner:   5,
            incharge:  false,
            activated: true,
            activated_at: Time.zone.now)
