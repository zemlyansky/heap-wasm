(module
  ;; Import functions
  (import "functions" "compare" (func $compare (param $a i32)(param $b i32)(result i32)))
  (import "functions" "log" (func $log (param $a i32)))

  ;; Memory
  (memory $mem (export "mem") 1 10000)

  ;; Global variables
  (global $size (mut i32) (i32.const 0))

  ;; Export functions
  (export "setSize" (func $setSize))
  (export "getSize" (func $getSize))
  (export "add" (func $add))
  (export "pop" (func $pop))
  (export "peek" (func $peek))
  (export "deleteTop" (func $deleteTop))
  (export "heapify" (func $heapify))

  ;; Returns size of heap
  (func $getSize (result i32)
    (get_global $size)
  )

  ;; Sets size of heap
  (func $setSize (param $s i32)
    (set_global $size (get_local $s))
  )
  
  ;; Finds a parent node
  (func $_parent (param $i i32) (result i32)
    (i32.shr_s (i32.sub (get_local $i)(i32.const 1))(i32.const 1))
  )

  ;; Recalculates heap
  (func $_siftUp (param $i i32)
    (local $p i32)
    (local $pval i32)
    (local $ival i32)
    ;; if (i > 0)
    (if (i32.gt_s (get_local $i)(i32.const 0)) (then
      (set_local $p (call $_parent (get_local $i)))
      (set_local $ival (i32.load (i32.mul (get_local $i)(i32.const 4))))
      (set_local $pval (i32.load (i32.mul (get_local $p)(i32.const 4))))
      (if (call $compare (get_local $pval)(get_local $ival)) (then
        (i32.store (i32.mul (get_local $p)(i32.const 4))(get_local $ival))
        (i32.store (i32.mul (get_local $i)(i32.const 4))(get_local $pval))
        (call $_siftUp (get_local $p))
      ))
    ))
  )

  (func $_siftDown (param $i i32)
    (local $l i32)
    (local $r i32)
    (local $ext i32)
    (local $temp i32)
    ;; Left children index <- i * 2 + 1
    (set_local $l (i32.add (i32.shl (get_local $i)(i32.const 1))(i32.const 1)))
    ;; Right children index <- i * 2 + 2
    (set_local $r (i32.add (i32.shl (get_local $i)(i32.const 1))(i32.const 2)))
    ;; Finding extremum (bigger or smaller)
    (set_local $ext (get_local $i))
    (if (i32.lt_s (get_local $l)(get_global $size)) 
      (then 
        (if 
          (call $compare 
            (i32.load (i32.mul (get_local $ext)(i32.const 4)))
            (i32.load (i32.mul (get_local $l)(i32.const 4)))
          )
          (then
            (set_local $ext (get_local $l))
          )
        )
      )
    )
    (if (i32.lt_s (get_local $r)(get_global $size))
      (then
        (if 
          (call $compare 
            (i32.load (i32.mul (get_local $ext)(i32.const 4)))
            (i32.load (i32.mul (get_local $r)(i32.const 4)))
          )
          (then
            (set_local $ext (get_local $r))
          )
        )
      )
    )
    (if (i32.ne (get_local $i)(get_local $ext))
      (then
        (set_local $temp (i32.load (i32.mul (get_local $i)(i32.const 4))))
        (i32.store (i32.mul (get_local $i)(i32.const 4)) (i32.load (i32.mul (get_local $ext)(i32.const 4))))
        (i32.store (i32.mul (get_local $ext)(i32.const 4)) (get_local $temp))
        (call $_siftDown (get_local $ext))
      )
    )
  )

  (func $add (param $val i32)
    (local $i i32)
    ;; Grow memory if needed
    (if
      (i32.ge_s
        ;; (size + 1) * 4
        (i32.shl (i32.add (get_global $size)(i32.const 1))(i32.const 2))
        ;; (current_memory * 64 * 1024) ~ (current_memory << 16)
        (i32.shl (current_memory)(i32.const 16))
      )
      (then
        ;; grow_memory return old page amount. discard it with drop()
        (drop (grow_memory (i32.const 1)))
      )
    )
    ;; i <- size
    (set_local $i (get_global $size))
    ;; mem[size * 4 ] <- val
    (i32.store (i32.mul (get_global $size)(i32.const 4)) (get_local $val))
    ;; siftUp(i)
    (call $_siftUp (get_global $size))
    ;; size += 1
    (set_global $size (i32.add (get_global $size)(i32.const 1)))
  )

  (func $deleteTop
    (set_global $size (i32.sub (get_global $size)(i32.const 1)))
    (if (i32.gt_s (get_global $size) (i32.const 0))
      (then
        (i32.store (i32.const 0)(i32.load (i32.mul(get_global $size)(i32.const 4))))
        (call $_siftDown (i32.const 0))
      )
    )
  )

  (func $pop (result i32)
    (local $result i32)
    (set_local $result (i32.load (i32.const 0)))
    (call $deleteTop)
    (get_local $result)
  )

  (func $peek (result i32)
    (i32.load (i32.const 0))
  )

  (func $heapify
    (local $i i32)
    (set_local $i (i32.sub (i32.shr_u (get_global $size)(i32.const 1))(i32.const 1)))
    (if (i32.ge_s (get_local $i)(i32.const 0))
      (then
        (loop $siftEach
          (call $_siftDown (get_local $i))
          (set_local $i (i32.sub (get_local $i)(i32.const 1)))
          (br_if $siftEach (i32.ge_s (get_local $i)(i32.const 0)))
        )
      )
    )
  )
)
