module OptionsValidator
  def validate_options(provided, *allowed_keys)
    raise(ArgumentError, "Valid options: #{allowed_keys}") unless (provided.keys - allowed_keys).empty?
  end
end
