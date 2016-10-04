class DataProcessHelpers
  def self.extract_tags(s)
    cand = /[tT]ags?\s*:\s*(.*)/.match s
    if cand and cand.size > 1
      cand[1].split(',').map { |i| i.strip }
    else
      []
    end
  end

  def self.hyperlink_pattern
    /(http.?:\/\/[^\s]+)/
  end
end
