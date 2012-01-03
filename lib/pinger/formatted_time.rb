class FormattedTime < Time
    
  def formatted
    self.strftime('%m/%d/%Y %I:%M:%S%p').downcase.gsub(/(^|\/)0/, '\1').gsub(/\s0/, ' ')
  end
  
end
