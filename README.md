# SimpleStore

A simple key:value store that supported dotted anotation thanks to [dot-prop](https://github.com/sindresorhus/dot-prop).

## Installation

Via npm on Node:

```
npm install dottystore
```

Reference in your program:

```js
const { Store } = require('dottystore')
```

## Usage

```js
const store = new Store()

store.set('some.value', true)
console.log(store.get('some.value')) // == true
```

## Development

```
git clone git@github.com/loicmahieu/dottystore.git
cd dottystore
npm install
npm test
```

## Contribution

Feel free to [file issues](https://github.com/loicmahieu/dottystore/issues) and submit
[pull requests](https://github.com/loicmahieu/dottystore/pulls) � contributions are
welcome.
