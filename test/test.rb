require "insist"
require "net/ssh"
require "json"
require "stud/try"
require "stud/temporary"
require "peach"

require_relative "helpers"
Thread.abort_on_exception = true

raise "What tags to run?" if ARGV.empty?

start = Time.now
queue = Queue.new

puts "Testing on #{ARGV.size} platforms:"
puts ARGV.join(", ")
puts
ARGV.each do |tag|
  Thread.new do
    out = Stud::Temporary.pathname
    err = Stud::Temporary.pathname
    begin
      status = test_in_container(tag, [
        ". /etc/profile; cd /pleaserun; rvm use 1.9.3; bundle install --quiet",
        ". /etc/profile; cd /pleaserun; rvm use 1.9.3; rspec --format json"
      ], out, err)
    rescue Insist::Failure
      status = false
    end
    queue << [tag, status, out, err]
  end
end

results = ARGV.collect { tag, success, out, err = queue.pop }
successes = results.count { |tag, success, out, err| success }
failures = results.count { |tag, success, out, err| !success }
tests = results.collect { |tag, success, out, err| 
  begin
    JSON.parse(File.read(out).split("\n").last[/{.*$/])["examples"].each { |r| r["tag"] = tag }
  rescue TypeError, NoMethodError
    puts "Failed to parse json"
    puts :out => File.read(out)
    puts :err => File.read(err)
    raise
  end
}.flatten

duration = Time.now - start

test_successes = tests.count { |t| t["status"] == "passed" }
test_failures = tests.count { |t| t["status"] == "failed" }

#require "pry"
#tests.pry
tests.each do |result|
  next if result["status"] == "passed"

  case result["status"]
    when "failed"
      puts "#{result["tag"]}: #{result["full_description"]}"
      exception = result["exception"]
      puts "  #{exception["class"]}: #{exception["message"]}"
    when "pending"
      puts "#{result["tag"]}: PENDING: #{result["full_description"]}"
  end
  puts "  #{result["file_path"]}:#{result["line_number"]}"
end

puts "Tests: #{test_successes} ok, #{test_failures} failures; Platforms: #{successes} ok, #{failures} failures;, Duration: #{sprintf("%0.3f", duration)} seconds"

results.each do |tag, success, out, err|
  File.delete(err)
  File.delete(out)
end

exit(results.any? { |t,s,*args| !s } ? 1 : 0)
