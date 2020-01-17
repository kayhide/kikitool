{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "kikitool"
, dependencies =
    [ "affjax"
    , "argonaut-codecs"
    , "console"
    , "debug"
    , "effect"
    , "formatters"
    , "precise-datetime"
    , "profunctor-lenses"
    , "psci-support"
    , "react-basic-hooks"
    , "web-dom"
    , "web-html"
    ]
, packages = ./packages.dhall
, sources = [ "app/frontend/packs/**/*.purs", "test/frontend/**/*.purs" ]
}
