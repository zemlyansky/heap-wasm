var Heap = require('.')

var h1 = new Heap()

h1.add(4)
h1.add(10)
h1.add(3)
h1.add(15)
h1.add(1)
h1.add(8)

console.log(h1.pop())
console.log(h1.getMem())

var h2 = new Heap()

h2.heapify([1,3,62,8,2,99])
console.log(h2.getMem())
