Name
====

lua-resty-queue, event driven ring queue implemented by ngx semaphore.

Description
===========

This Lua library implements a ring queue based on ngx.semaphore which ensures no blocking behavior.

* [Methods](#methods)
    * [new](#new)
    * [size](#size)
    * [capacity](#capacity)
    * [full](#full)
    * [empty](#empty)
    * [push](#push)
    * [pop](#pop)
    * [clear](#clear)

Methods
======

### new

`syntax: q, err = queue:new([option:table])`

- `option:table`
  - `capacity`: number (optional) - capacity for the ring buffer default `1024`
  - `blocked`: boolean (optional) - whether the queue is a blocked queue
  - `timeout`: number (optional) - seconds for waiting semaphore default 3 while specified a blocked queue, notice that if the queue is not a blocked queue, this option has no effect.

In case of success this method returns a queue entity,  in case of error, it returns nil with a string describing the error. 

[Back to TOP](#name)

### size

`syntax: len = queue:size()`

Get the number of elements.

### capacity

`syntax: cap = queue:capacity()`

Get the capacity of queue.

[Back to TOP](#name)

### full

`syntax: cap = queue:full()`

Checks whether the queue is full.

[Back to TOP](#name)

### empty

`syntax: cap = queue:empty()`

Checks whether the queue is empty.

[Back to TOP](#name)

### push

`syntax: ok, err = queue:push(element, wait?)`

- element can be any type except `nil`
- wait boolean (optional) - whether to wait, default wait on blocked queue. Notice that if the queue is not a blocked queue, this option has no effect.

Push element to the tail of queue. A blocked queue will be blocked until queue is not full by default and user can control return at once while the queue is full by settng `wait` option to `false`. In case of push failed, it returns nil with a string describing the error.

[Back to TOP](#name)

### pop

`syntax: element = queue:pop(wait?)`

- element can be any type except `nil`
- wait boolean (optional) - whether to wait,, default wait on blocked queue. Notice that if the queue is not a blocked queue, this option has no effect.

Pop element at the head of queue. A blocked queue will be blocked until queue is not empty by default and user can control return at once while the queue is empty by settng `wait` option to `false`.

[Back to TOP](#name)

### clear

`syntax: queue:clear()`

Clear the queue.

[Back to TOP](#name)
