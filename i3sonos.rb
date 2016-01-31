#!/usr/bin/env ruby

STDOUT.sync = true

require 'json'
require 'sonos'

# Silense the output of Sonos::System.new as it prints "Timed out..." to
# STDOUT, which is invalid JSON when read by i3bar.
def silence_stdout
  $stdout = File.new('/dev/null', 'w')
  yield
ensure
  $stdout = STDOUT
end

def do_nothing
  loop do
    puts "#{$stdin.gets},"
    redo
  end
end

# print the version
puts $stdin.gets

# print the first bit of the header
puts $stdin.gets

s_name = ARGV[0]
# If no speaker name was passed as argument, see if ~/.i3sonos.conf has it
if s_name.nil? || s_name.empty?
  config_file = File.read(File.expand_path("~/.i3sonos.conf"))
  config = JSON.parse(config_file)
  if config['enabled'] != true
    do_nothing
  end

  unless config['speaker'].nil?
    s_name = config['speaker']
  else
    do_nothing
  end
end

system = silence_stdout { Sonos::System.new }
speaker = system.speakers.select { |s| s.name.downcase == s_name.downcase }

# If no matching speakers found, just return.
if speaker.size < 0
  puts "${$stdin.gets},"
  return
else
  speaker = speaker[0]
end

loop do
  t = Time.now.to_i
  i3status_line = $stdin.gets
  i3status_line.sub!(/^,?/, "")
  i3_json = JSON.parse(i3status_line)

  # If more than 60 seconds have passed, do a new system discovery.
  # Or if we don't have a proper system to work with, in that case
  # try a rediscovery much sooner.
  if (Time.now.to_i - t >= 60) ||
     (system.devices.empty? && Time.now.to_i - 1 >= 10)
    system = silence_stdout { Sonos::System.new }

    # Update our t
    t = Time.now.to_i
  end

  # If there are no devices, just return the i3status output.
  if system.devices.empty?
    puts "#{i3status_line.chomp},"
    redo
  end

  # get the current track or return empty string if nothing was found,
  # or the speaker isn't available anymore.
  track = "#{speaker.now_playing[:artist]} - #{speaker.now_playing[:title]}"

  state = speaker.get_player_state[:state]
  if state == 'PLAYING'
    color = "#00FF00"
    symbol = "\u9654"
  else
    color = "#FFFF00"
    symbol = "\u9632"
  end

  sonos_json = {
    :name => 'sonos',
    :instance => speaker.name,
    :full_text => track,
    :color     => color,
    :markup => "none",
  }

  new_statusline = [sonos_json, i3_json].flatten
  puts "#{new_statusline.to_json.sub!(/,/, ", ")},"
end
