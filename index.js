var heapWasmInit = require('./heap.wasm.js')

var defaultComp = function (a, b) {
  return a < b
}

function Heap (comp, arr) {
  if (!(this instanceof Heap)) return new Heap(comp)
  var compare = comp || defaultComp
  var heapWasm = heapWasmInit({
    imports: {
      functions: {
        compare: compare,
        log: function (x) { console.log(x) }
      }
    }
  })
  var mem = new Uint32Array(heapWasm.exports.mem.buffer)
  this.getSize = heapWasm.exports.getSize
  this.setSize = heapWasm.exports.setSize
  if (arr && arr.length) {
    // arr.forEach((v, i) => { mem[i] = v })
    mem.set(arr, 0)
    this.setSize(arr.length)
    heapWasm.exports.heapify()
  }
  this.add = heapWasm.exports.add
  this.peek = function () {
    if (this.getSize()) {
      return heapWasm.exports.peek()
    } else {
      return undefined
    }
  }
  this.pop = function () {
    if (this.getSize()) {
      return heapWasm.exports.pop()
    } else {
      return undefined
    }
  }
  this.getMem = function () {
    return Array.from(mem.slice(0, this.getSize()))
  }
  this.heapify = function (arr) {
    //arr.forEach((v, i) => { mem[i] = v })
    mem.set(arr, this.getSize())
    this.setSize(this.getSize() + arr.length)
    heapWasm.exports.heapify()
  }
}

module.exports = Heap
