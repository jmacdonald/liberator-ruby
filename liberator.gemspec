Gem::Specification.new do |s|
  s.name        = 'liberator'
  s.version     = '0.1.0'
  s.date        = '2013-04-11'
  s.summary     = "Disk space management tool."
  s.description = "Liberator helps you find and delete files and directories consuming large amounts of space. It uses a curses interface and is ideally suited for *nix servers running without a GUI."
  s.authors     = ["Jordan MacDonald"]
  s.email       = 'jordan@wastedintelligence.com'
  s.files       = ["lib/liberator.rb"]
  s.homepage    = 'https://github.com/jmacdonald/liberator'
  s.executables << 'liberator'
end
