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
total_tests = 0
tests = results.collect { |tag, success, out, err| 
  JSON.parse(File.read(out).split("\n").last[/{.*$/])["examples"].each { |r| r["tag"] = tag }
}.flatten

duration = Time.now - start

test_successes = tests.count { |t| t["status"] == "passed" }
test_failures = tests.count { |t| t["status"] == "failed" }

puts "Tests: #{test_successes} ok, #{test_failures} failures; Platforms: #{successes} ok, #{failures} failures;, Duration: #{sprintf("%0.3f", duration)} seconds"

results.each do |tag, success, out, err|
  # print only on failure *or* if only one container is run
  if !success || results.size == 1
    puts File.read(err).gsub(/^/, "#{tag}/stderr: ")
    puts File.read(out).gsub(/^/, "#{tag}/stdout: ")
  end
  File.delete(err)
  File.delete(out)
end

exit(results.any? { |t,s,*args| !s } ? 1 : 0)
