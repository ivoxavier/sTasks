stasks_sources = [
  'main.vala',
  'window.vala',
  'about.vala',
  stasks_resources # Esta variável agora vem do data/meson.build!
]

stasks_deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
]

executable('stasks', stasks_sources,
  dependencies: stasks_deps,
  install: true,
)