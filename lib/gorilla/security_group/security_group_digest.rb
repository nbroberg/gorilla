class SecurityGroupDigest < AbstractDigest

  def digest(group_name)
    rules = Gorilla::SecurityGroup.get_rules(group_name)

    unless rules.empty?
      return self[group_name] = rules
    end

    puts "No rules to digest, security group is empty or does not exist"
    false
  end

end