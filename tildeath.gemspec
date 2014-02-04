require_relative 'lib/tildeath/version'

Gem::Specification.new do |s|
  s.name = 'tildeath'
  s.version = Tildeath::VERSION

  s.summary = 'An esoteric language interpreter for the imminently deceased.'
  s.description = 'An esoteric language interpreter for the imminently deceased.'

  s.author = 'Rob Steward'
  s.email = 'bobert_1234567890@hotmail.com'
  s.homepage = 'https://github.com/filialpails/tildeath'
  s.license = 'GPL-3.0'

  s.files = Dir['README.md', 'LICENSE', 'examples/*.rb', 'lib/**/*.rb', 'bin/*']
  s.bindir = 'bin'
  s.executables = ['tildeath']
end
