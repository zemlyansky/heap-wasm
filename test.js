var test = require('ava').test
var Heap = require('.')
var values

test('Create heap', t => {
  var h = new Heap()
  t.is(h.constructor, Heap)
})

test('New heap has 0 length', t => {
  var h = new Heap()
  t.is(h.getSize(), 0)
})

test('New heap returns empty array', t => {
  var h = new Heap()
  t.deepEqual(h.getMem(), [])
})

// Maximum value on the top
values = [
  [[10], [10]],
  [[12, 5, 7, 1, 78, 24, 3, 6], [78, 12, 24, 6, 5, 7, 3, 1]],
  [[9, 15, 13, 17, 12, 8, 5, 100, 19, 6, 11, 36, 25, 1, 4], [100, 19, 36, 17, 12, 25, 5, 9, 15, 6, 11, 8, 13, 1, 4]]
]
values.forEach(pair => {
  test('Max. Add: ' + pair[0].toString() + ' -> ' + pair[1].toString(), t => {
    var h = new Heap()
    pair[0].forEach(v => {
      h.add(v)
    })
    t.deepEqual(h.getMem(), pair[1])
  })
})

// Minimum on the top
values = [
  [[10], [10]],
  [[12, 5, 7, 1, 78, 24, 3, 6], [1, 5, 3, 6, 78, 24, 7, 12]],
  [[9, 15, 13, 17, 12, 8, 5, 100, 19, 6, 11, 36, 25, 1, 4], [1, 6, 4, 17, 11, 13, 5, 100, 19, 15, 12, 36, 25, 9, 8]]
]
values.forEach(pair => {
  test('Min. Add: ' + pair[0].toString() + ' -> ' + pair[1].toString(), t => {
    var h = new Heap((a, b) => a > b)
    pair[0].forEach(v => {
      h.add(v)
    })
    t.deepEqual(h.getMem(), pair[1])
  })
})

// Pop element
values = [
  [[], [], undefined],
  [[10], [], 10],
  [[12, 5, 7, 1, 78, 24, 3, 6], [3, 5, 7, 6, 78, 24, 12], 1],
  [[9, 15, 13, 17, 12, 8, 5, 100, 19, 6, 11, 36, 25, 1, 4], [4, 6, 5, 17, 11, 13, 8, 100, 19, 15, 12, 36, 25, 9], 1]
]
values.forEach(pair => {
  var h = new Heap((a, b) => a > b)
  pair[0].forEach(v => {
    h.add(v)
  })
  var p = h.pop()
  test('Pop value. Add: ' + pair[0].toString() + ' -> ' + pair[2], t => {
    t.is(p, pair[2])
  })
  test('Heap after pop: ' + pair[1].toString(), t => {
    t.deepEqual(h.getMem(), pair[1])
  })
})
