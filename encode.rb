#!/usr/bin/env ruby -w
require 'rubygems'
require 'rvideo' || begin
  `sudo aptitude install ffmpeg`
  `sudo gem sources -a http://gems.github.com`
  `sudo gem install mhs-rvideo`
end and require 'rvideo'

class HBEncoder
  def self.encode(path, type = 'mkv')
    (files = Dir[File.join(File.expand_path(path), "**", "*.mkv")].sort).each_with_index do |file, i|
      begin
        original = ::RVideo::Inspector.new(:file => file)
        output_file = "#{File.join(File.dirname(file), File.basename(file, type))}m4v"
        puts "Skipping #{file} as destination exists" and next if File.exists?(output_file) 
        puts "Encoding file #{i + 1} of #{files.size}..."
        hb_cmd = "HandBrakeCLI -i '#{file}' -o '#{output_file}' --preset=\"High Profile\""
        puts "CMD: #{hb_cmd}"
        $stdout.sync = true
        system("#{hb_cmd} 2>/dev/null")
        new = ::RVideo::Inspector.new(:file => output_file)
        if new.duration == original.duration
          puts "File duration matches"
          puts "Would like to delete"
        else
          puts "New duration #{new.duration}, old duration #{original.duration}"
          puts "Would leave alone"
        end
      rescue SignalException => e
        print "Cleaning up..."
        File.unlink(output_file)
        puts "...done"
        return -1
      end
    end
  end
end

raise "Usage: Encode <path>" unless ARGV.size == 1
path = ARGV.first
HBEncoder.encode(path)

