
path = require 'path'
chai = require 'chai'
assert = chai.assert
expect = chai.expect
chai.should()
chai.use(require('chai-spies'))

requireTest = (path) ->
  require((process.env.APP_SRV_COVERAGE || '../') + path)

requireStore = -> requireTest('lib/store')
getStore = (opt) -> new (requireStore())(opt)

describe 'Config', ->
  [config] = []

  it 'is a class', ->
    expect(requireStore()).to.be.a('function')


describe 'Config::get', ->
  [config] = []

  before ->
    config = getStore()
    config._data =
      foo: 'bar'
      bar:
        foo: 'bar'
      baz: ['a', 'b', 'c']
      foobar: true

  it 'Can get a string', ->
    expect(config.get('foo')).to.be.equals('bar')

  it 'Can get an array', ->
    expect(config.get('baz')).to.deep.equal(['a', 'b', 'c'])

  it 'Can get an object', ->
    expect(config.get('bar')).to.deep.equal({'foo': 'bar'})

  it 'Can get a boolean', ->
    expect(config.get('foobar')).to.equal(true)


describe 'Config::set', ->
  [config] = []

  before ->
    config = getStore()

  testWrite = (prop, value, equality, called = 1, forceUpdate) ->
    spy = chai.spy (data) -> equality(data)
    config.once("updated.#{prop}", spy)

    _save = config._save
    config._save = chai.spy config._save

    config.set(prop, value, forceUpdate)

    if called
      expect(spy).to.have.been.called(called)
      expect(config._save).to.have.been.called(called)
    else
      expect(spy).to.not.have.been.called
      expect(config._save).to.not.have.been.called

    equality(config.get(prop))

    config._save = _save

  it 'Can set a string', ->
    testWrite('foo', 'bar', (v) -> expect(v).to.be.equals('bar'))

  it 'Can set a string already exists', ->
    testWrite('foo', 'bar', ((v) -> expect(v).to.be.equals('bar')), false)

  it 'Can get an array', ->
    testWrite('baz', ['a', 'b', 'c'], (v) -> expect(v).to.deep.equals(['a', 'b', 'c']))

  it 'Can get an object', ->
    testWrite('bar', {'foo': 'bar'}, (v) -> expect(v).to.deep.equals({'foo': 'bar'}))

  it 'Can get a boolean', ->
    testWrite('foobar', true, (v) -> expect(v).to.be.equals(true))

  describe 'ForceUpdate', ->
    it 'Do not trigger save if set the same object', ->
      obj = {'foo': 'bar'}
      testWrite('obj', obj, (v) -> expect(v).to.deep.equals({'foo': 'bar'}))
      testWrite('obj', obj, ((v) -> expect(v).to.deep.equals({'foo': 'bar'})), 0)

    it 'Trigger save if set the same object if forceUpdate = true', ->
      obj = {'foo': 'bar'}
      testWrite('obj', obj, (v) -> expect(v).to.deep.equals({'foo': 'bar'}))
      testWrite('obj', obj, ((v) -> expect(v).to.deep.equals({'foo': 'bar'})), 1, true)


describe 'config::toggle', ->
  [config] = []

  before ->
    config = getStore()

  it 'Toggle undefined to true', ->
    config.toggle('to.exists')
    expect(config.get('to.exists')).to.be.equals(true)

  it 'Toggle false to true', ->
    config.set('must.be.false', false)
    config.toggle('must.be.false')
    expect(config.get('must.be.false')).to.be.equals(true)

  it 'Toggle true to false', ->
    config.set('must.be.true', true)
    config.toggle('must.be.true')
    expect(config.get('must.be.true')).to.be.equals(false)


describe 'config::del', ->
  [config] = []

  before ->
    config = getStore()

  testDelete = (prop, called = 1) ->
    spy = chai.spy (data) -> expect(data).to.be.undefined
    config.once("updated.#{prop}", spy)

    _save = config._save
    config._save = chai.spy config._save

    config.del(prop)

    if called
      expect(spy).to.have.been.called(called)
      expect(config._save).to.have.been.called(called)
    else
      expect(spy).to.not.have.been.called
      expect(config._save).to.not.have.been.called

    expect(config.get(prop)).to.be.undefined

    config._save = _save

  it 'Delete a string', ->
    config.set('to.delete', 'str')
    testDelete('to.delete')


describe 'config::setDefaults', ->
  [config, dir] = []

  before ->
    config = getStore()
    config._data =
      some:
        path1: 'overwrite'

  it 'Can set somes defaults', ->
    config.setDefaults
      some:
        path: 'foo:bar'
        path1: 'bar:foo'
    config.set('some.path1', 'overwrite')
    expect(config.get('some.path')).to.be.equals('foo:bar')

