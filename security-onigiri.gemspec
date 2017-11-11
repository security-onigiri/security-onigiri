# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "security-onigiri"
  spec.version       = "0.0.2"
  spec.authors       = ["bananaappletw"]
  spec.email         = ["bananaappletw@gmail.com"]

  spec.summary       = %q{security onigiri: jekyll theme for translated articles}
  spec.homepage      = "https://github.com/security-onigiri/security-onigiri"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(assets|_layouts|_includes|_sass|LICENSE|README)}i) }

  spec.add_runtime_dependency "jekyll", "~> 3.5"
  spec.add_runtime_dependency "jekyll-assets"
  spec.add_runtime_dependency "jekyll-coffeescript"
  spec.add_runtime_dependency "jekyll-paginate"
  spec.add_runtime_dependency "jekyll-feed"
  spec.add_runtime_dependency "jekyll-sitemap"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
