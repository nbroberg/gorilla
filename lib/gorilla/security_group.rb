module Gorilla
  module SecurityGroup

    GROUP_DESCRIPTION = "Group Automatically Generated by Gorilla"

    # Getters / Setters

    @@digest_file = Gorilla.digest_folder + "/security_groups.yml"

    def self.digest_file
      @@digest_file
    end

    def self.digest_file=(digest_file)
      @@digest_file = digest_file
    end

    # Common Rest Connection Functionality

    def self.find(group_name)
      group = Ec2SecurityGroup.find(:first) do |g| 
        g.aws_group_name == group_name
      end

      group
    end

    def self.get_rules(group_name)
      group = Gorilla::SecurityGroup.find(group_name)

      acceptable_rule_parameters =  [
                                      'owner', 
                                      'group', 
                                      'cidr_ips', 
                                      'protocol', 
                                      'from_port', 
                                      'to_port'
                                    ]

      rules = []

      return rules if group == nil

      group.aws_perms.each do |original_rule|
        rule = {}
        original_rule.each do |key,value|
          if acceptable_rule_parameters.include?(key)
            rule[key] = value
          end
        end
        rules.push(rule)
      end

      rules
    end

    # Security Group Manipulation Helper Methods

    def self.group_diff(source_group, destination_group)
      differences = {}

      missing_rules = self.missing_rules(source_group, destination_group)
      extra_rules = self.extra_rules(source_group, destination_group)
      
      differences = {"missing" => missing_rules, "extra" => extra_rules}
    end

    def self.missing_rules(source_group,destination_group)
      missing_rules = []
      source_group.each do |rule|
        unless destination_group.include?(rule)
          missing_rules.push(rule)
        end
      end
      missing_rules
    end

    def self.extra_rules(source_group,destination_group)
      extra_rules = []
      destination_group.each do |rule|
        unless source_group.include?(rule)
          extra_rules.push(rule)
        end
      end
      extra_rules
    end

    def self.synchronize(group_name,source_rules={})
      group = Gorilla::SecurityGroup.find(group_name)
      
      if group
        puts "Security group '#{group_name}' already exists."

        destination_rules = self.get_rules(group_name)
        group_differences = self.group_diff(source_rules,destination_rules)

        if group_differences['missing'].empty? and group_differences['extra'].empty?
          puts "There is no difference between source and destination security group"
          return true
        elsif Gorilla.dry_run
          unless group_differences['missing'].empty?
            puts "The following rules need to be added from the destination group:"
            puts group_differences['missing'].to_yaml
          end
          unless group_differences['extra'].empty?
            puts "The following rules need to be removed from the destination group:"
            puts group_differences['extra'].to_yaml
          end
          return false
        end
      end

      if Gorilla.dry_run
        puts "Will not add security group '#{group_name}' (dry-run)"
        return false  
      elsif group
        group.destroy
      end

      group_parameters =  {
                            :aws_group_name => group_name, 
                            :aws_description=> GROUP_DESCRIPTION,
                            :cloud_id => '1'
                          }

      group = Ec2SecurityGroup.create(group_parameters)

      unless source_rules.empty?
        source_rules.each do |rule|
          group.add_rule(rule)
        end
      end

      true
    end

    # Main Security Group Manipulation Methods

    def self.digest(group_name)
      digest = SecurityGroupDigest.from_file(SecurityGroup.digest_file)

      digest.digest(group_name)
    end

    def self.diff(source_group,destination_group)
      source_rules = self.get_rules(source_group)

      destination_rules = self.get_rules(destination_group)

      group_differences = self.group_diff(source_rules, destination_rules)

      if group_differences['missing'].empty? and group_differences['extra'].empty?
        puts "Security groups are identical"
      elsif not group_differences['missing'].empty?
        puts "The following rules need to be added from the destination group:"
        puts group_differences['missing'].to_yaml
      elsif not group_differences['extra'].empty?
        puts "The following rules need to be removed from the destination group:"
        puts group_differences['extra'].to_yaml
      end
    end

    def self.copy(source_group,destination_group)
      rules = self.get_rules(source_group)

      self.synchronize(destination_group,rules)
    end

    def self.update(group_name)
      digest = SecurityGroupDigest.from_file(SecurityGroup.digest_file)

      unless digest.has_key?(group_name)
        puts "No digest found for security group '#{group_name}'"
        return false
      end

      rules = digest[group_name]

      self.synchronize(group_name,rules)
    end

    def self.delete(group_name)
      if Gorilla.dry_run
        puts "Will not delete security group '#{group_name}' (dry-run)"
        return false  
      else
        group = Gorilla::SecurityGroup.find(group_name)
      
        if group
          group.destroy
          return true
        else
          puts "Cannot delete group '#{group_name}', it does not exist"
          return false
        end
      end
    end

  end
end