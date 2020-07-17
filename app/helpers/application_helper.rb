module ApplicationHelper


  # We use base 35 and replace O by Z to avoid zero
  # This method duplicate in Application Controller !!!
  def encode_client_ref(fname, id, ref)
    if fname.length == 1 then
      return  (fname[0..0] + 'X-' + (id.to_s + ref.to_s.rjust(3, "0")).to_i.to_s(35)).upcase.upcase.gsub(/O/, 'Z')
    end
    return  (fname[0..1] + '-' + (id.to_s + ref.to_s.rjust(3, "0")).to_i.to_s(35)).upcase.gsub(/O/, 'Z')
  end


  #---------------- Read SP
  def read_proc_result(raw_result, row, proc_name)
    readArray = ''
    begin
      puts '---------------- split_appointment ----------------'
      raw_resultsplitted = raw_result[row][proc_name].to_s
      puts 'size: ' + raw_resultsplitted.to_s.length.to_s
      # Remove last letter which )
      raw_resultsplitted[raw_resultsplitted.to_s.length - 1] = ''
      # Remove first letter which (
      # Be carefull this zero is not the first row
      raw_resultsplitted[0] = ''
      raw_resultsplitted = raw_resultsplitted.split(",")
      #puts 'split: ' + raw_resultsplitted.to_s
      readArray = raw_resultsplitted
    rescue Exception => msg
      logger.error 'Issue reading Gen Proc: ' + msg.to_s
      readArray = ''
    end
    return readArray.to_s

  end

  def mobile_device
    agent = request.user_agent
    return "tablet" if agent =~ /(tablet|ipad)|(android(?!.*mobile))/i
    return "mobile" if agent =~ /Mobile/
    return "desktop"
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = ENV['titlepage']
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
