class ApplicationController < ActionController::Base
  include SessionsHelper
  require 'mailjet'

  require 'net/http'
  require 'uri'

  private

  def get_partner_company_name
    puts '!@current_user.nil? : ' + (!@current_user.nil?).to_s
    puts '@current_user.partner : ' + @current_user.partner.to_s
    if (!@current_user.nil?) and (@current_user.partner.to_i > 1)

      unless !@resultSetCompany.nil?
        sql_query = "SELECT id, name, description, COALESCE(to_phone, 'NR') AS pphone, COALESCE(website, 'NR') AS pwebsite, cur_code, hdl_price, hdl_pickup, hdl_calc_pricing, hdl_mother, hdl_merge FROM ref_partner rp WHERE id = " + @current_user.partner.to_s + ";"
        begin
          #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
          #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
          @resultSetCompany = ActiveRecord::Base.connection.exec_query(sql_query).cast_values
        end
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

  # Be careful this method exists on JS
  # as pure unhappy duplicate code
  def encodeMGS(id, sec, st = "B")
    # Here is JS content
    # let lidPlusSec = parseInt(lid.toString() + mgspad(sec, 4).toString());
    # return 'M' + mgspad(lidPlusSec.toString(36), 8).toUpperCase();

    # Convert base
    # 12345.to_s(36)
    # => "9ix"
    # "9ix".to_i(36)
    # => 12345

    # Padding zero
    # puts 1.to_s.rjust(3, "0")
    #=> 001
    # puts 10.to_s.rjust(3, "0")
    #=> 010
    # puts 100.to_s.rjust(3, "0")
    #=> 100
    # n1 = sec.to_s.rjust(4, '0')
    # puts 'encodeMGS n1:' + n1
    # n2 = (id.to_s + n1).to_i
    # puts 'encodeMGS n2:' + n2.to_s
    # n3 = n2.to_s(36).rjust(8, '0')
    # puts 'encodeMGS n3:' + n3
    return (st + (id.to_s + sec.to_s.rjust(4, '0')).to_i.to_s(36).rjust(ENV['BC_REF_LIMIT'].to_i, '0')).upcase

  end



  # Mailer
  def sendEmailNotification(to_addr, firstname_name, cb_code, status, msg)
    Mailjet.configure do |config|
      config.api_key = ENV['MJ_APIKEY_PUBLIC']
      config.secret_key = ENV['MJ_APIKEY_PRIVATE']
      config.api_version = "v3.1"
    end
    variable = Mailjet::Send.create(messages: [{
        'From'=> {
            'Email'=> ENV['MJ_SEND_MAIL'],
            'Name'=> 'MG Suivi notification'
        },
        'To'=> [
            {
                'Email'=> to_addr,
                'Name'=> firstname_name
            }
        ],
        'Subject' => 'MGS: ' + cb_code + ' ' + status,
        'TextPart'=> 'Cher.ère utilisateur.rice, nous avons du nouveau pour vous ! Votre paquet : ' + cb_code + ' est passé à #' + status + ". " +  msg + " Pour plus de détails, tapez " + cb_code + " dans notre barre de recherche.",
        'HTMLPart'=> 'Cher.ère utilisateur.rice, <br> nous avons du nouveau pour vous ! Votre paquet : ' + cb_code + ' est passé à #' + status + ". " +  msg + "<br> Pour plus de détails, tapez " + cb_code + " dans notre barre de recherche."
    }]
    )
    # p is the function loggin the message to the terminal
    p variable.attributes['Messages']
    puts "EMAIL Notification: " + variable.inspect


  end

  # Mailer
  def sendPlainEmail(to_addr, subject, msg)
    Mailjet.configure do |config|
      config.api_key = ENV['MJ_APIKEY_PUBLIC']
      config.secret_key = ENV['MJ_APIKEY_PRIVATE']
      config.api_version = "v3.1"
    end
    variable = Mailjet::Send.create(messages: [{
        'From'=> {
            'Email'=> ENV['MJ_SEND_MAIL'],
            'Name'=> 'MG Suivi notification'
        },
        'To'=> [
            {
                'Email'=> to_addr,
                'Name'=> 'Utilisateur.rice'
            }
        ],
        'Subject' => 'MGS: ' + subject,
        'TextPart'=> 'Cher.ère utilisateur.rice, nous avons du nouveau pour vous ! ' + msg.gsub(/<br>/, "\n") + ' Ne répondez pas à cet email. Il ne sera pas lu.',
        'HTMLPart'=> 'Cher.ère utilisateur.rice, <br> nous avons du nouveau pour vous ! <br>' + msg+ '<br><br><br>Ne répondez pas à cet email. Il ne sera pas lu.'
    }]
    )
    # p is the function loggin the message to the terminal
    p variable.attributes['Messages']
    puts "EMAIL Notification: " + variable.inspect

  end


end
