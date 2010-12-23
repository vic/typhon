require 'rake/gempackagetask'

task :default => :spec

desc "Run the specs (default)"
task :spec => :build do
  sh "mspec spec"
end

desc "Clean generated files"
task :clean do
  rm_f FileList["**/*.{pyc,rbc}"]
  rm_rf FileList["pkg"]
end

task :build

spec = Gem::Specification.new do |s|
  require File.expand_path('../lib/typhon/version', __FILE__)

  s.name                      = "typhon"
  s.version                   = Typhon::VERSION.to_s

  s.specification_version     = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors                   = ["Victor Hugo Borja"]
  s.date                      = %q{2010-12-18}
  s.email                     = %q{vic.borja@gmail.com}
  s.has_rdoc                  = true
  s.extra_rdoc_files          = %w[ README.md ]
  s.executables               = ["typhon"]
  s.files                     = FileList[ '{bin,lib,spec}/**/*.{yaml,txt,rb}', 'Rakefile', *s.extra_rdoc_files ]
  s.homepage                  = %q{http://github.com/vic/typhon}
  s.require_paths             = ["lib"]
  s.rubygems_version          = %q{1.3.5}
  s.summary                   = "A Python implementation for the Rubinius VM."
  s.description               = <<EOS
Typhon is a Python implementation that runs on the Rubinius VM.
EOS

  s.rdoc_options << '--title' << 'Typhon: snakes on rubinius head' <<
                    '--main' << 'README.md' <<
                    '--line-numbers'
  s.add_dependency 'mspec', '~> 1.5.0'
end

Rake::GemPackageTask.new(spec){ |pkg| pkg.gem_spec = spec }
