
_ = require 'lodash'
util = require 'util'
Promise = require 'bluebird'
contentful = require 'contentful'

ACTIVITIES = '9A2oSPrer66KO48uwmqEo'
CONTACTS = '4f0abwsEisQkKOcsGkSws6'
VIEWS = '4cbcatG768QMMGKWGyAKy8'
PRODUCT_CATEGORIES = 'yFltYdnOUgYSk24cs2Oyo'
PRODUCTS = '5HIBLLRLk4OeSgGYa2SECe'

if not process.env.CONTENTFUL_ACCESS_TOKEN
  throw new Error 'Missing Contentful access token'

client = contentful.createClient
  space: '0si2zg5epbkb'
  accessToken: process.env.CONTENTFUL_ACCESS_TOKEN
  resolveLinks: true


products = client.entries(content_type: PRODUCTS).then (products) ->

  categories = products.reduce (categories, product) ->

    category = product.fields.category

    id = _.kebabCase category.fields.title

    categories[id] = categories[id] or
      id: id
      title: category.fields.title
      thumbnail: category.fields.thumbnail?.fields.file.url
      items: []

    categories[id].items.push _.extend product.fields,
      thumbnail: product.fields.thumbnail?.fields.file.url
      image: product.fields.image?.fields.file.url

    categories
  , {}

activities = client.entries(content_type: ACTIVITIES)
.then (activities) ->
  _.map activities, (activity) ->
    _.extend activity.fields,
      cover: activity.fields.cover?.fields.file.url
      thumbnail: activity.fields.thumbnail?.fields.file.url
      id: _.kebabCase activity.fields.title

contacts = client.entries(content_type: CONTACTS).then (contacts) ->
  contacts[0].fields

getActivities = (season) ->
  activities.then (activities) ->
    _(activities).filter (activity) ->
      activity.season is season
    .indexBy 'id'
    .value()

views = client.entries(content_type: VIEWS).then (views) ->

  Promise.all _.map views, (view) ->

    view = _.extend view.fields,
      cover: view.fields.cover?.fields.file.url
      thumbnail: view.fields.thumbnail?.fields.file.url

    if view.id in ['summer', 'winter', 'adventures']
      return getActivities(view.id).then (activities) ->
        _.extend view, {activities}

    view

.then (views) ->
  _.indexBy views, 'id'

getContent = ->
  Promise.props {views, contacts, products}

module.exports.getContent = getContent
