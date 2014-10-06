require 'rake/testtask'

task :default => [:test]
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/**/*_test.rb"
end

desc 'Seed the suggestion engine'
task 'mindtrick:seed' do
  require './app'
  Unitwise.search('').each do |u|
    %w{names primary_code symbol}.each do |a|
      Suggestor.seed u.to_s(a)
    end
  end
end
