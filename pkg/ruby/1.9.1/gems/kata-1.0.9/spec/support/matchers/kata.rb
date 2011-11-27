RSpec::Matchers.define :have_summary do |expected|
  match do |string|
    string == expected
  end 
end

RSpec::Matchers.define :have_requirement do |summary, requirement|
  match do |string|
    string.split(/\n\n/)[0] == "#{summary}\n   #{requirement}"
  end 
end

RSpec::Matchers.define :have_examples do |summary, requirement, examples|
  example_str = examples.unshift('').join("\n      - example: ")
  match do |string|
    string.split(/completed \(Y|n\)/)[0].strip == "#{summary}\n   #{requirement}#{example_str}"
  end 
end

%w{url user token}.each do |method|
  RSpec::Matchers.define "have_#{method}".to_sym do |expected|
    match do |github|
      github.send(method) == expected
    end
  end
end
