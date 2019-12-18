const { environment } = require('@rails/webpacker')
const purescript =  require('./loaders/purescript')

environment.loaders.prepend('purescript', purescript)
module.exports = environment
