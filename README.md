# SimpleStore

[![Greenkeeper badge](https://badges.greenkeeper.io/LoicMahieu/dottystore.svg)](https://greenkeeper.io/)

A simple key:value store that supported dotted anotation thanks to [dotty](https://github.com/deoxxa/dotty).

## Installation

Via npm on Node:

```
npm install dottystore
```

Reference in your program:

```js
var Store = require('dottystore');
```

## Usage

```js
var store = new Store();

store.set('some.value', true);
console.log(store.get('some.value')) // == true
```

## Development

```
git clone git@github.com/loicmahieu/dottystore.git
cd dottystore
npm install
grunt test
```

## Contribution

Feel free to [file issues](https://github.com/loicmahieu/dottystore/issues) and submit
[pull requests](https://github.com/loicmahieu/dottystore/pulls) — contributions are
welcome.
