class AbstractDigest < Hash
  
  attr_accessor :file_path

  def self.from_file(file_path)
    @file_path = file_path

    digest = self.new
    digest.file_path = file_path

    if File.exist?(file_path)
      yaml = File.read(file_path)

      hash = YAML::load(yaml)

      digest.replace(hash)
    end

    digest
  end

  def synchronize
    updated_yaml = self.to_yaml

    File.open(@file_path, 'w') do |file| 
      file.write(updated_yaml) 
    end

    self
  end

  def []=(key,value)
    self.store(key,value)

    self.synchronize
  end

  def delete(key)
    super.delete(key)

    self.synchronize
  end

end