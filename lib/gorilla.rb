require "rubygems"
require "rest_connection"
require "ruby-debug"

module Gorilla
    @@cloud_id = 1

    def self.cloud_id
      @@cloud_id
    end

    def self.cloud_id=(cloud_id)
      @@cloud_id = cloud_id
    end

    @@digest_folder = "#{ENV['HOME']}/gorilla_digests"

    def self.digest_folder
      @@digest_folder
    end

    def self.digest_folder=(digest_folder)
      @@digest_folder = digest_folder
    end

    @@dry_run = false

    def self.dry_run
      @@dry_run
    end

    def self.dry_run=(dry_run)
      @@dry_run = dry_run
    end
end

require 'fileutils'
unless File.directory?(Gorilla.digest_folder)
  FileUtils.mkdir_p Gorilla.digest_folder
end

require "gorilla/version"

require "gorilla/security_group"
require "gorilla/abstract_digest"
require "gorilla/security_group/security_group_digest"
require "gorilla/security_group/auditor"
