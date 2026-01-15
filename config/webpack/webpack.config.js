// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')
const path = require('path')

const webpackConfig = generateWebpackConfig()

// Force webpack to use a single copy of React to avoid "invalid hook call" errors
webpackConfig.resolve.alias = {
  ...webpackConfig.resolve.alias,
  'react': path.resolve(__dirname, '../../node_modules/react'),
  'react-dom': path.resolve(__dirname, '../../node_modules/react-dom')
}

module.exports = webpackConfig
