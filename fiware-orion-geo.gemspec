Gem::Specification.new do |s|
  s.name        = 'fiware-orion-geo'
  s.version     = '0.0.3'
  s.date        = '2014-08-03'
  s.summary     = 'Interface for Orion server'
  s.description = 'Gives you the possibility to simply interfear with Orion server (from Fiware) to insert and retrieve data based on geolocalisation'
  s.authors     = ['Nikolaï POSNER']
  s.email       = 'nikoposner@gmail.com'
  s.homepage    = 'https://github.com/NikoEEMI/fiware-orion-geo'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.add_runtime_dependency 'httparty', '~> 0'
end