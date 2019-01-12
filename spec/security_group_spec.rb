require 'lib/gorilla'

describe Gorilla::SecurityGroup do

  before(:all) do
    @example_digest_path = "spec/example_digests/security_groups.yml"
    @original_digest_file_contents = File.read(@example_digest_path)
    example_digest = YAML::load(File.open(@example_digest_path))
    @test_groups = example_digest.keys
  end

  before(:each) do
    Gorilla::SecurityGroup.digest_file = @example_digest_path
    Gorilla.dry_run = false
  end

  it "searches for security groups with open port 80" do
    matching_groups = Gorilla::SecurityGroup::Auditor::search(80,'0.0.0.0/0')
   
    matching_group_names = []
    matching_groups.each do |group| 
      matching_group_names.push(group.aws_group_name)
    end

    matching_group_names.include?("default").should be_true
  end

  it "creates security groups from example digest" do
    @test_groups.each do |group_name|
      Gorilla::SecurityGroup.update(group_name).should be_true
    end
  end

  it "copies a security group" do
    successful_copy = Gorilla::SecurityGroup.copy('gorilla_test_group_3','gorilla_test_group_4')

    successful_copy.should be_true

    @test_groups.push('gorilla_test_group_4') if successful_copy
  end

  it "digests the previously copied security group" do
    Gorilla::SecurityGroup.digest('gorilla_test_group_4').should be_true
  end

  it "attempts to create another group with dry-run parameter toggled on" do
    Gorilla.dry_run = true

    Gorilla::SecurityGroup.copy('gorilla_test_group_2','gorilla_test_group_3').should be_false
  end

  it "deletes the security groups used in the test" do
    @test_groups.each do |group_name|
      Gorilla::SecurityGroup.delete(group_name).should be_true
    end
  end

  after(:all) do
    File.open(@example_digest_path, 'w') do |file| 
      file.write(@original_digest_file_contents) 
    end
  end

end

