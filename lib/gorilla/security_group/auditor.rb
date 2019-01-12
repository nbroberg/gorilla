module Gorilla
  module SecurityGroup
    class Auditor

      def self.search(port,cidr,cloud_id=1)
        matching_groups = []

        groups_in_cloud = Ec2SecurityGroup.find_by_cloud_id(cloud_id)

        groups_in_cloud.each do |security_group|
          if security_group_matches(security_group,port,cidr)
            matching_groups.push(security_group)
          end
        end

        matching_groups
      end

      def self.security_group_matches(security_group,port,cidr)
        security_group.aws_perms.each do |permission|
          if permission.include?('cidr_ips') and permission['cidr_ips'] == cidr
            if permission['from_port'] == "-1" or port.between?(Integer(permission['from_port']), Integer(permission['to_port']))
                return true
            end
          end
        end
      end

    end
  end
end