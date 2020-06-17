module ApplicationHelper


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
