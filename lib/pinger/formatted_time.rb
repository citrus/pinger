module FormattedTime
  
  def formatted
    self.strftime('%m/%d/%Y %I:%M%p').downcase.gsub(/\s0'/, ' ')
  end
  
end
