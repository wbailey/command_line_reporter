module OptionsValidator
  def validate(provided)
    allowed = self.class::VALID_OPTIONS
    raise(ArgumentError, "Valid options: #{allowed}") unless (provided.keys - allowed).empty?
  end
end
