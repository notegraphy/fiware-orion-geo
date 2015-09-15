Gem::Specification.new do |s|
  s.name        = 'fiware-orion-geo'
  s.version     = '0.0.3'
  s.date        = '2014-08-03'
  s.summary     = 'Interface for Orion server'
  s.description = 'Gives you the possibility to simply interfear with Orion server (from Fiware) to insert and retrieve data based on geolocalisation'
  s.authors     = ['Nikolaï POSNER']
  s.email       = 'nikoposner@gmail.com'
  s.files       = `git ls-files`.split($\)
  s.homepage    = 'https://github.com/NikoEEMI/fiware-orion-geo'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', '~> 0'
  s.add_runtime_dependency 'httparty', '~> 0'
end