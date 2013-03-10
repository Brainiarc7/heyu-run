# Script for HEYU runner with state machine (target spidermonkey JS)
#
# by Pjotr Prins (c) 2013

load('lib/statemachine.js')

AssertError = (@message) ->

assert = (expr, message='', got='unknown') ->
  unless expr()
    print 'Assertion failed',message,expr
    print 'Got',got if got isnt 'unknown'
    throw new AssertError(message)

# ---- Clone objects
clone = (obj) ->
  return obj  if obj is null or typeof (obj) isnt "object"
  temp = obj.constructor()
  for key of obj
    temp[key] = clone(obj[key])
  temp

# ---- Read JSON file
read_json = (fn) ->
  file = new File("myfile.txt")
  file.open("read","text")
  buf = file.readln()
  file.close()
  buf

# ---- Write JSON
write_json = (fn,objs) ->
  # Try to write to a file
  file = new File("myfile.txt")
  file.remove() if file.exists
  file.open("write,create", "text")
  for obj in objs do
    file.writeln(obj.toJSON())
  file.close()
  # JSON.stringify obj

# ---- Display help
help = () ->
  print """
  Usage: heyu-run [args]

    --test     Run tests
  """
  throw new Error("Done.");

# ---- Check sanity of the environment
test = () ->
  print 'Running tests'
  # Test state machine
  sm = new StateMachine(states: ['OFF', 'ON']) # just make sure it compiles
  appl = new HeyuAppliance("light1")
  print "# Available states",appl.availableStates()
  appl.display_state()
  appl.switchOn()
  appl.display_state()
  appl.switchOff()
  appl.display_state()
  appl.switchOn()
  appl2 = new HeyuAppliance("light2")
  appl2.display_state()
  appl2.switchOn()
  appl2.display_state()
  appl2.switchOff()
  appl2.display_state()
  appl.display_state()
  print appl.currentState()
  assert((-> appl.currentState() is "ON"),appl.name,appl.currentState())
  assert((-> appl2.currentState() is "OFF"),appl2.name,appl2.currentState())
  write_json("myfile.txt",[appl,appl2])
  buf = read_json("myfile.txt")
  assert((-> buf is "test"),"read_json",buf)
  print 'Tests passed'

# ---- Parse the command line
parse_opts = (set,args) ->
  if args.length > 0
    args2 =
      switch args[0]
        when '--help' or '-h'
          help()
        when '--test'
          test()
          set.event = "on"
          set.id  = "test"
          args[1..]
        when '--id'
          set.id = args[1]
          args[2..]
        when '--switch'
          set.event = args[1]
          args[2..]
        else
          throw "Unknown argument #{args[0]}"
    parse_opts(set,args2) if args2.length > 0
    set

# ---- Main program
root = this
args = clone(root.arguments)  # don't need to do this, just for fun
set = parse_opts({test: test},args)
print "heyu",set.event,set.id
