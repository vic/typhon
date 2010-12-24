require 'rbconfig'

module Typhon

  module VERSION
    extend self

    attr_accessor :major, :minor, :tiny, :commit, :codename, :tagline

    self.codename = "Snakes on rbx-head"
    self.tagline = "Snakes on rbx-head"

    self.major = 0
    self.minor = 0
    self.tiny = 1

    def commit
      @commit ||= `git rev-parse HEAD`[0..7]
    end

    def to_s
      [major, minor, tiny].join(".")
    end

    def to_str
      to_s
    end

    def full_string(sep = "\n")
      [typhon_string, rbx_string].join(sep)
    end

    def typhon_string
      "Typhon #{to_s} (#{commit} #{python_string}) \"#{codename}\""
    end

    def python_string
      `python -V 2>&1`.chomp
    end

    # Returns a partial Ruby version string based on +which+. For example,
    # if RUBY_VERSION = 8.2.3 and RUBY_PATCHLEVEL = 71:
    #
    #  :major  => "8"
    #  :minor  => "8.2"
    #  :tiny   => "8.2.3"
    #  :teeny  => "8.2.3"
    #  :full   => "8.2.3.71"
    def self.ruby_version(which = :minor)
      case which
      when :major
        n = 1
      when :minor
        n = 2
      when :tiny, :teeny
        n = 3
      else
        n = 4
      end

      patch = RUBY_PATCHLEVEL.to_i
      patch = 0 if patch < 0
      version = "#{RUBY_VERSION}.#{patch}"
      version.split('.')[0,n].join('.')
    end

    def rbx_string
      "Rubinius #{Rubinius::VERSION} (#{ruby_version(:tiny)} "+
        "#{Rubinius::BUILD_REV[0..7]} #{Rubinius::RELEASE_DATE})"
    end
  end
end

