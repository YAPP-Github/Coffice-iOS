import ProjectDescription

let config = Config(
  plugins: [
    .local(path: .relativeToManifest("../../Plugins/coffice")),
  ]
)
