#!/usr/bin/env ruby

# Plugin validation script
puts "🔍 VALIDATING PLUGIN FILES..."

# Check required files exist
required_files = [
  'init.rb',
  'lib/dradis-user_issue_stats.rb', 
  'lib/dradis/plugins/user_issue_stats.rb',
  'lib/dradis/plugins/user_issue_stats/engine.rb',
  'lib/dradis/plugins/user_issue_stats/version.rb',
  'lib/dradis/plugins/user_issue_stats/gem_version.rb',
  'lib/dradis/plugins/user_issue_stats/configuration.rb',
  'lib/dradis/plugins/user_issue_stats/controllers/user_issue_stats_controller.rb',
  'lib/dradis/plugins/user_issue_stats/views/user_issue_stats/index.html.erb',
  'config/routes.rb',
  'dradis-user_issue_stats.gemspec'
]

base_path = File.dirname(__FILE__)
missing_files = []

required_files.each do |file|
  full_path = File.join(base_path, file)
  if File.exist?(full_path)
    puts "✅ #{file}"
  else
    puts "❌ #{file} - MISSING!"
    missing_files << file
  end
end

if missing_files.empty?
  puts "\n🎉 ALL REQUIRED FILES PRESENT!"
else
  puts "\n🔴 MISSING FILES: #{missing_files.join(', ')}"
  exit 1
end

# Check key configurations
puts "\n🔍 CHECKING CONFIGURATIONS..."

# Check gemspec includes init.rb
gemspec_content = File.read(File.join(base_path, 'dradis-user_issue_stats.gemspec'))
if gemspec_content.include?('init.rb')
  puts "✅ Gemspec includes init.rb"
else
  puts "❌ Gemspec missing init.rb in files list"
end

# Check init.rb has correct registration
init_content = File.read(File.join(base_path, 'init.rb'))
if init_content.include?('user_issue_stats') && init_content.include?('UserIssueStats')
  puts "✅ init.rb has correct registration"
else
  puts "❌ init.rb registration incorrect"
end

# Check engine has plugin name
engine_content = File.read(File.join(base_path, 'lib/dradis/plugins/user_issue_stats/engine.rb'))
if engine_content.include?('plugin_name')
  puts "✅ Engine has plugin_name method"
else
  puts "❌ Engine missing plugin_name method"
end

puts "\n🎯 PLUGIN VALIDATION COMPLETE!"
puts "📦 Ready for installation in Dradis!"
