class ApplicationController < ActionController::Base
  include SessionsHelper
  require 'mailjet'


  private

  def get_partner_company_name
    unless !@resultSetCompany.nil?
      sql_query = "SELECT id, name, description, COALESCE(to_phone, 'NR') AS pphone, COALESCE(website, 'NR') AS pwebsite FROM ref_partner WHERE id = " + @current_user.partner.to_s + ";"
      begin
        #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
        #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
        @resultSetCompany = ActiveRecord::Base.connection.exec_query(sql_query).cast_values
      end
    end
  end

  # This method need to be use everytime we have a string VARCHAR to had
  # It contains already the quote
  def get_safe_pg_wq(str)
    if str.nil? then
      return "NULL"
    elsif str == ''
      return "NULL"
    else
      return " TRIM('" + str.gsub(/"|'|!|>|;/, '') + "')"
    end
  end
  #Special no whitespace
  def get_safe_pg_wq_ns(str)
    if str.nil? then
      return "NULL"
    elsif str == ''
      return "NULL"
    else
      return " TRIM('" + str.gsub(/"|'|!|>|;|\s/, '') + "')"
    end
  end

  #Special no whitespace double quote no trim
  def get_safe_pg_wq_ns_notrim_doublequote(str)
    if str.nil? then
      return "NULL"
    elsif str == ''
      return "NULL"
    else
      return '"' + str.gsub(/"|'|!|>|;|\s/, '') + '"'
    end
  end

  #Special no whitespace
  def get_safe_pg_number(str)
    if str.nil? then
      return "NULL"
    elsif str == ''
      return "NULL"
    else
      return str.gsub(/"|'|!|>|;|\s/, '')
    end
  end

  def gen_dual_not_safe_clause(i, j)
    return '(' + i + ', '+ j + ')'
  end

  # Mailer

  def sendEmailTest
    Mailjet.configure do |config|
      config.api_key = ENV['MJ_APIKEY_PUBLIC']
      config.secret_key = ENV['MJ_APIKEY_PRIVATE']
      config.api_version = "v3.1"
    end
    variable = Mailjet::Send.create(messages: [{
        'From'=> {
            'Email'=> 'mgsuivi@protonmail.com',
            'Name'=> 'MG Suivi Notifictions'
        },
        'To'=> [
            {
                'Email'=> 'tsikyharimino@gmail.com',
                'Name'=> 'passenger 1'
            }
        ],
        'Subject'=> 'Nouvelle information concernant votre paquet',
        'TextPart'=> 'Cher.ère utilisateur.rice, nous avons du nouveau pour vous !',
        'HTMLPart'=> '<h3>Cher.ère utilisateur.rice, nous avons du nouveau pour vous !'
    }]
    )
    p variable.attributes['Messages']

  end

end
