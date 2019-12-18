{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "kikitool"
, dependencies = [ "console", "effect", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "app/frontend/packs/**/*.purs", "test/frontend/**/*.purs" ]
}
